#' Find the IUCN Red List threat category interactively
#'
#' An interactive decision tree that walks you through the five IUCN Red List
#' criteria (A to E) like a form filled in at the console, and tells you which
#' threatened category (Critically Endangered, Endangered or Vulnerable) your
#' values meet. You can go back to any earlier question to change an answer,
#' and you review all your answers before the result is shown.
#'
#' @details
#' Start by choosing the criteria you have data for; only the questions for
#' those criteria are asked. At every prompt you can type:
#' \describe{
#'   \item{`b`}{go back to the previous question;}
#'   \item{`q`}{quit without a result;}
#'   \item{`?`}{show help for the current question;}
#'   \item{Enter}{keep your current answer when you come back to a question,
#'     or leave an optional value unknown;}
#'   \item{`na`}{set an optional value back to unknown.}
#' }
#'
#' The thresholds are those of the summary of the five criteria in the IUCN
#' Red List Categories and Criteria:
#'
#' | Criterion | CR | EN | VU |
#' |---|---|---|---|
#' | A1 reduction | >= 90% | >= 70% | >= 50% |
#' | A2, A3, A4 reduction | >= 80% | >= 50% | >= 30% |
#' | B1 extent of occurrence | < 100 km2 | < 5,000 km2 | < 20,000 km2 |
#' | B2 area of occupancy | < 10 km2 | < 500 km2 | < 2,000 km2 |
#' | B(a) number of locations | 1 | <= 5 | <= 10 |
#' | C mature individuals | < 250 | < 2,500 | < 10,000 |
#' | C2a(i) largest subpopulation | <= 50 | <= 250 | <= 1,000 |
#' | C2a(ii) share in one subpopulation | 90-100% | 95-100% | 100% |
#' | D mature individuals | < 50 | < 250 | < 1,000 (D1) |
#' | E probability of extinction | >= 50% in 10 years or 3 generations | >= 20% in 20 years or 5 generations | >= 10% in 100 years |
#'
#' Criterion B also needs at least two of the conditions (a) severe
#' fragmentation or a limited number of locations, (b) continuing decline and
#' (c) extreme fluctuations. Criterion C also needs a continuing decline (C1)
#' or a continuing decline with a small or concentrated subpopulation
#' structure or extreme fluctuations (C2). D2 (a very restricted range facing a
#' plausible, fast-acting threat) applies to Vulnerable only. When both are
#' given and the extent of occurrence is smaller than the area of occupancy,
#' the extent of occurrence is raised to equal it, as the guidelines require.
#'
#' A taxon is listed in the most threatened category that any criterion
#' qualifies it for. When no criterion is met, the taxon does not qualify for a
#' threatened category on the information given; it may be Near Threatened,
#' Least Concern or Data Deficient, which this function does not decide.
#'
#' This is a screening aid, not a formal assessment. Read the definitions of
#' the terms used (location, severe fragmentation, continuing decline, extreme
#' fluctuations) in the IUCN guidelines before listing a taxon.
#'
#' @return Invisibly, an object of class `rl_threat_category`: a list with
#'   \describe{
#'     \item{`category`}{`"CR"`, `"EN"`, `"VU"`, or `NA` when no threatened
#'       category is met;}
#'     \item{`criteria`}{the criteria met at that category, for example
#'       `"A2; B1ab"`, or `NA`;}
#'     \item{`details`}{a tibble with one row per criterion assessed and the
#'       columns `criterion`, `category`, `code` and `reason`;}
#'     \item{`answers`}{a list of the values you entered.}
#'   }
#'   Printing the object shows the report again. If you quit, `NULL` is
#'   returned invisibly.
#'
#' @references
#' IUCN. 2012. IUCN Red List Categories and Criteria: Version 3.1. Second
#' edition. Gland, Switzerland and Cambridge, UK: IUCN.
#'
#' IUCN Standards and Petitions Committee. 2024. Guidelines for Using the IUCN
#' Red List Categories and Criteria. Version 16.
#' \url{https://cmsdocs.s3.amazonaws.com/RedListGuidelines.pdf}
#'
#' @seealso [rl_reduction()] to estimate a population reduction for
#'   criterion A, [rl_eoo()] and [rl_aoo()] for the criterion B range metrics,
#'   and [rl_generation_length()].
#'
#' @examples \dontrun{
#' res <- rl_threat_category()
#' res$category
#' res$details
#' }
#' @export
rl_threat_category <- function() {
  if (!rlang::is_interactive()) {
    cli::cli_abort(c(
      "{.fn rl_threat_category} needs an interactive R session.",
      i = "Run it from R or RStudio console."
    ))
  }

  rl_tc_intro()
  answers <- rl_tc_run(rl_tc_steps(), read = rl_tc_read)
  if (is.null(answers)) {
    cli::cli_alert_warning("No category was computed.")
    return(invisible(NULL))
  }

  res <- rl_tc_decide(answers)
  print(res)
  invisible(res)
}


#' @export
print.rl_threat_category <- function(x, ...) {
  cli::cli_h1("IUCN Red List threat category")

  d <- x$details
  if (nrow(d) == 0) {
    cli::cli_alert_info("No criterion was assessed.")
  }
  for (r in seq_len(nrow(d))) {
    badge <- rl_tc_badge(d$category[r])
    reason <- cli::col_grey(d$reason[r])
    cli::cli_text("{badge} {.strong Criterion {d$criterion[r]}}  {reason}")
  }

  cli::cli_rule()
  if (is.na(x$category)) {
    cli::cli_alert_info(
      "Does not meet a threatened category (CR, EN or VU) on the information given."
    )
    cli::cli_text(cli::col_grey(
      "It may be Near Threatened, Least Concern or Data Deficient; these are not decided here."
    ))
  } else {
    label <- rl_tc_labels[[x$category]]
    badge <- rl_tc_badge(x$category)
    cli::cli_text("{badge} {.strong {label}}  {.code {x$category} {x$criteria}}")
  }
  cli::cli_rule()
  cli::cli_text(cli::col_grey(
    "A screening aid, not a formal assessment."
  ))

  invisible(x)
}


# ################################################################################
# The form is one entry per question, in the order they are asked. `when` hides a
# question until the answers so far make it relevant.
#####################################################
#' @noRd
rl_tc_steps <- function() {
  in_scope <- function(k) {
    force(k)
    function(a) k %in% a$scope
  }
  b_has_range <- function(a) {
    "B" %in% a$scope && (!is.na(rl_tc_num(a$b_eoo)) || !is.na(rl_tc_num(a$b_aoo)))
  }
  c_open <- function(a) "C" %in% a$scope && isTRUE(rl_tc_num(a$mature) < 10000)
  c2_open <- function(a) c_open(a) && isTRUE(a$c2_decline)

  list(
    list(
      id = "scope", group = "scope", type = "multi", label = "Criteria",
      title = "Which criteria do you have data for?",
      choices = c(
        A = "A: Population size reduction",
        B = "B: Geographic range (EOO / AOO)",
        C = "C: Small population size and decline",
        D = "D: Very small or restricted population",
        E = "E: Quantitative analysis (probability of extinction)"
      ),
      help = "Pick every criterion you have information for; only their questions are asked. The taxon is listed in the most threatened category that any criterion supports."
    ),

    # Criterion A
    list(
      id = "a_basis", group = "A", type = "choice", when = in_scope("A"),
      label = "A subcriterion",
      title = "Which situation describes the reduction?",
      choices = c(
        A1 = "A1: In the past; the causes are clearly reversible AND understood AND have ceased",
        A2 = "A2: In the past; the causes may not have ceased, be understood or be reversible",
        A3 = "A3: Projected or suspected in the future (up to 100 years)",
        A4 = "A4: Over a window covering past and future; the causes may not have ceased, be understood or be reversible"
      ),
      help = "A1 uses higher thresholds (90, 70, 50%) because the causes are reversible, understood and have ceased. A2, A3 and A4 share lower thresholds (80, 50, 30%)."
    ),
    list(
      id = "a_reduction", group = "A", type = "number", when = in_scope("A"),
      label = "Reduction (%)", unit = "%", min = 0, max = 100,
      title = "Population reduction (%)",
      note = "Measured over the longer of 10 years or 3 generations.",
      help = "The reduction in the number of mature individuals, as a percentage, for example 65.7. rl_reduction() estimates it from population counts."
    ),

    # Criterion B
    list(
      id = "b_eoo", group = "B", type = "number", when = in_scope("B"),
      optional = TRUE, min = 0, label = "EOO (km\u00b2)",
      title = "B1: Extent of occurrence, EOO (km\u00b2)",
      note = "CR < 100, EN < 5,000, VU < 20,000 km\u00b2.",
      help = "The area of the smallest convex polygon containing all known sites. Leave empty if unknown. rl_eoo() computes it from occurrence records."
    ),
    list(
      id = "b_aoo", group = "B", type = "number", when = in_scope("B"),
      optional = TRUE, min = 0, label = "AOO (km\u00b2)",
      title = "B2: Area of occupancy, AOO (km\u00b2)",
      note = "CR < 10, EN < 500, VU < 2,000 km\u00b2.",
      help = "The area of the occupied cells of a 2 x 2 km grid. Leave empty if unknown. rl_aoo() computes it from occurrence records."
    ),
    list(
      id = "b_fragmented", group = "B", type = "yesno", when = b_has_range,
      optional = TRUE, label = "Severely fragmented",
      title = "Is the population severely fragmented?",
      note = "Condition (a), first part.",
      help = "Severely fragmented: most individuals (more than half) live in small, relatively isolated subpopulations."
    ),
    list(
      id = "b_locations", group = "B", type = "number", when = b_has_range,
      optional = TRUE, integer = TRUE, min = 1, label = "Locations",
      title = "Number of locations",
      note = "Condition (a), second part: 1 (CR), \u2264 5 (EN), \u2264 10 (VU).",
      help = "A location is an area in which a single threatening event can rapidly affect all the individuals present. Leave empty if unknown."
    ),
    list(
      id = "b_decline", group = "B", type = "yesno", when = b_has_range,
      optional = TRUE, label = "Continuing decline",
      title = "Is there a continuing decline?",
      note = "Condition (b): in EOO, AOO, habitat area, extent or quality, number of locations or subpopulations, or mature individuals.",
      help = "Answer y if a continuing decline is observed, estimated, inferred or projected in any one of these."
    ),
    list(
      id = "b_fluct", group = "B", type = "yesno", when = b_has_range,
      optional = TRUE, label = "Extreme fluctuations",
      title = "Are there extreme fluctuations?",
      note = "Condition (c): in EOO, AOO, number of locations or subpopulations, or mature individuals.",
      help = "Extreme fluctuations are large, rapid and frequent changes, typically more than tenfold between the highs and the lows."
    ),

    # Criteria C and D share the population size 
    list(
      id = "mature", group = "N", type = "number",
      when = function(a) any(c("C", "D") %in% a$scope),
      integer = TRUE, min = 0, label = "Mature individuals",
      title = "Number of mature individuals",
      help = "The number of individuals known, estimated or inferred to be capable of reproduction. Criteria C and D both use it."
    ),

    # Criterion C 
    list(
      id = "c1_rate", group = "C", type = "choice", when = c_open,
      label = "C1 decline",
      title = "C1: Which continuing decline is reached?",
      choices = c(
        none = "None of these, or unknown",
        VU = "At least 10% in 10 years or 3 generations",
        EN = "At least 20% in 5 years or 2 generations",
        CR = "At least 25% in 3 years or 1 generation"
      ),
      note = "Observed, estimated or projected, over the longer of the two periods, up to 100 years ahead.",
      help = "Pick the most severe line your continuing decline reaches. Choose 'None' when no rate is known; C2 may still apply."
    ),
    list(
      id = "c2_decline", group = "C", type = "yesno", when = c_open,
      label = "C2 continuing decline",
      title = "C2: Is there a continuing decline in mature individuals?",
      help = "At any rate, observed, estimated, projected or inferred. C2 also needs one of the conditions asked next."
    ),
    list(
      id = "c2_subpop", group = "C", type = "number", when = c2_open,
      optional = TRUE, integer = TRUE, min = 0, label = "Largest subpopulation",
      title = "C2a(i): Mature individuals in the largest subpopulation",
      note = "Met when every subpopulation has \u2264 50 (CR), \u2264 250 (EN) or \u2264 1,000 (VU).",
      help = "The number of mature individuals in the largest subpopulation. Leave empty if unknown."
    ),
    list(
      id = "c2_pct", group = "C", type = "number", when = c2_open,
      optional = TRUE, min = 0, max = 100, unit = "%",
      label = "Share in one subpopulation (%)",
      title = "C2a(ii): Share of mature individuals in one subpopulation (%)",
      note = "Met at 90-100% (CR), 95-100% (EN) or 100% (VU).",
      help = "The percentage of all mature individuals found in a single subpopulation. Leave empty if unknown."
    ),
    list(
      id = "c2_fluct", group = "C", type = "yesno", when = c2_open,
      optional = TRUE, label = "C2b fluctuations",
      title = "C2b: Extreme fluctuations in the number of mature individuals?",
      help = "Large, rapid and frequent changes, typically more than tenfold between the highs and the lows."
    ),

    # Criterion D 
    list(
      id = "d2", group = "D", type = "yesno", when = in_scope("D"),
      optional = TRUE, label = "D2 restricted range",
      title = "D2: Very restricted range facing a plausible, fast-acting threat?",
      note = "Typically AOO < 20 km\u00b2 or \u2264 5 locations, with a threat that could drive the taxon to CR or EX in a very short time. Vulnerable only.",
      help = "Answer y only if a specific, plausible threat could make the taxon Critically Endangered or Extinct within one or two generations."
    ),

    # Criterion E 
    list(
      id = "e_prob", group = "E", type = "choice", when = in_scope("E"),
      label = "Probability of extinction",
      title = "Which probability of extinction in the wild is reached?",
      choices = c(
        none = "None of these",
        VU = "At least 10% within 100 years",
        EN = "At least 20% within 20 years or 5 generations (100 years at most)",
        CR = "At least 50% within 10 years or 3 generations (100 years at most)"
      ),
      note = "From a quantitative analysis, such as a population viability analysis.",
      help = "Pick the most severe line your analysis reaches."
    ),

    list(
      id = "review", group = "review", type = "review",
      title = "Check your answers",
      help = "Type b to go back and change an answer, or press Enter to see the result."
    )
  )
}


# #################
# Running the form
# ################

# Read one line from the console. Kept as its own function so it can be
# replaced when testing.
#' @noRd
rl_tc_read <- function(prompt) {
  readline(prompt) # nocov
}

#' @noRd
rl_tc_visible <- function(st, answers) {
  is.null(st$when) || isTRUE(st$when(answers))
}

# Every question of the chosen criteria, whether or not the answers so far
# make it relevant. Counting these keeps the "(k/m)" total steady: skipped
# questions make k jump ahead rather than m grow.
#' @noRd
rl_tc_planned <- function(st, answers) {
  switch(st$group,
    scope = ,
    review = TRUE,
    N = any(c("C", "D") %in% answers$scope),
    st$group %in% answers$scope
  )
}

# Walk the questions, moving back and forth as asked. Returns the list of
# answers, or NULL if the user quits.
#' @noRd
rl_tc_run <- function(steps, read = rl_tc_read) {
  answers <- list()
  i <- 1L
  last_group <- NULL

  while (i <= length(steps)) {
    st <- steps[[i]]
    if (!rl_tc_visible(st, answers)) {
      i <- i + 1L
      next
    }

    header <- FALSE
    if (!identical(st$group, last_group)) {
      header <- rl_tc_group_header(st$group)
      last_group <- st$group
    }
    if (!header) cli::cat_line()

    counter <- NULL
    if (!is.null(answers$scope)) {
      planned <- which(vapply(steps, rl_tc_planned, logical(1), answers = answers))
      counter <- c(match(i, planned), length(planned))
    }

    visible <- which(vapply(steps, rl_tc_visible, logical(1), answers = answers))
    res <- rl_tc_ask(st, answers, counter, read, steps)

    if (identical(res$action, "quit")) {
      return(NULL)
    }
    if (identical(res$action, "back")) {
      earlier <- visible[visible < i]
      if (length(earlier) == 0L) {
        cli::cli_alert_info("This is the first question.")
      } else {
        i <- max(earlier)
      }
      next
    }

    answers[st$id] <- list(res$value)
    i <- i + 1L
  }

  # Going back and changing an answer can hide questions answered earlier;
  # drop those answers so they do not count.
  for (st in steps) {
    if (!rl_tc_visible(st, answers)) answers[[st$id]] <- NULL
  }
  answers$review <- NULL
  answers
}

# Show one question and read answers until a valid one, or a command, comes.
#' @noRd
rl_tc_ask <- function(st, answers, counter, read, steps) {
  current <- answers[[st$id]]
  has_current <- !is.null(current) && st$type != "review"
  rl_tc_show(st, answers, counter, steps)

  repeat {
    x <- trimws(read(paste0(cli::col_cyan(cli::symbol$pointer), " ")))
    cmd <- rl_tc_command(x)

    if (identical(cmd, "help")) {
      help <- st$help %||% "No extra help for this question."
      cli::cli_alert_info("{help}")
      next
    }
    if (!is.null(cmd)) {
      return(list(action = cmd))
    }
    if (!nzchar(x) && has_current) {
      return(list(action = "next", value = current))
    }

    parsed <- rl_tc_parse(st, x)
    if (!is.null(parsed$error)) {
      msg <- parsed$error
      cli::cli_alert_danger("{msg}")
      next
    }
    return(list(action = "next", value = parsed$value))
  }
}

#' @noRd
rl_tc_command <- function(x) {
  x <- tolower(x)
  if (x %in% c("b", "back")) return("back")
  if (x %in% c("q", "quit", "exit")) return("quit")
  if (x %in% c("?", "h", "help")) return("help")
  NULL
}

# Turn typed text into a value for the question, or an error message.
#' @noRd
rl_tc_parse <- function(st, x) {
  ok <- function(v) list(value = v)
  bad <- function(msg) list(error = msg)
  lx <- tolower(x)
  unknown <- !nzchar(x) || lx %in% c("na", "-", "unknown")

  switch(st$type,
    review = ok(TRUE),

    number = {
      if (unknown) {
        if (isTRUE(st$optional)) return(ok(NA_real_))
        return(bad("A value is needed here. Type a number, or b to go back."))
      }
      if (grepl(",", x, fixed = TRUE)) {
        return(bad("Please type the number without commas, for example 20000 or 12.5."))
      }
      v <- suppressWarnings(as.numeric(gsub("[[:space:]_]", "", x)))
      if (is.na(v)) {
        return(bad(sprintf("'%s' is not a number.", x)))
      }
      if (!is.null(st$min) && v < st$min) {
        return(bad(sprintf("The value must be at least %s.", st$min)))
      }
      if (!is.null(st$max) && v > st$max) {
        return(bad(sprintf("The value must be at most %s.", st$max)))
      }
      if (isTRUE(st$integer) && v != round(v)) {
        return(bad("Please type a whole number."))
      }
      ok(v)
    },

    yesno = {
      if (unknown) {
        if (isTRUE(st$optional)) return(ok(NA))
        return(bad("Please answer y (yes) or n (no)."))
      }
      if (lx %in% c("y", "yes", "o", "oui", "true")) return(ok(TRUE))
      if (lx %in% c("n", "no", "non", "false")) return(ok(FALSE))
      bad("Please answer y (yes) or n (no).")
    },

    choice = {
      n <- length(st$choices)
      j <- rl_tc_pick(x, n)
      if (length(j) != 1L || is.na(j)) {
        return(bad(sprintf("Please type one number between 1 and %d.", n)))
      }
      ok(names(st$choices)[j])
    },

    multi = {
      n <- length(st$choices)
      if (lx %in% c("all", "*")) return(ok(names(st$choices)))
      parts <- strsplit(x, "[,;[:space:]]+")[[1]]
      j <- vapply(parts[nzchar(parts)], rl_tc_pick, integer(1), n = n)
      if (length(j) == 0L || anyNA(j)) {
        return(bad(sprintf("Please type numbers between 1 and %d, for example 1,3, or all.", n)))
      }
      ok(names(st$choices)[sort(unique(j))])
    }
  )
}

# Options are chosen by their number only, so that letters stay free for the
# commands (b, q).
#' @noRd
rl_tc_pick <- function(x, n) {
  if (!grepl("^[0-9]+$", x)) return(NA_integer_)
  j <- as.integer(x)
  if (j < 1L || j > n) NA_integer_ else j
}


# #######
# Display
# #######

rl_tc_labels <- c(CR = "Critically Endangered", EN = "Endangered", VU = "Vulnerable")

#' @noRd
rl_tc_intro <- function() {
  cli::cli_h1("IUCN Red List threat category")
  cli::cli_text(
    "Answer the questions to see which threatened category (CR, EN or VU) your values meet under criteria A to E."
  )
  cli::cli_text(cli::col_grey(
    "At any prompt: b = back: q = quit: ? = help: Enter = keep the current answer"
  ))
}

#' @noRd
rl_tc_group_header <- function(group) {
  title <- switch(group,
    A = "Criterion A: Population size reduction",
    B = "Criterion B: Geographic range",
    N = "Population size: criteria C and D",
    C = "Criterion C: Small population size and decline",
    D = "Criterion D: Very small or restricted population",
    E = "Criterion E: Quantitative analysis",
    review = "Review",
    NULL
  )
  if (!is.null(title)) cli::cli_h2("{title}")
  invisible(!is.null(title))
}

#' @noRd
rl_tc_show <- function(st, answers, counter, steps) {
  current <- answers[[st$id]]
  has_current <- !is.null(current) && st$type != "review"

  progress <- if (is.null(counter)) "" else cli::col_grey(sprintf("(%d/%d)", counter[1], counter[2]))
  cli::cli_text("{.strong {st$title}} {progress}")
  if (!is.null(st$note)) {
    cli::cli_text(cli::col_grey("{st$note}"))
  }

  if (st$type %in% c("choice", "multi")) {
    codes <- names(st$choices)
    for (j in seq_along(codes)) {
      picked <- has_current && codes[j] %in% current
      mark <- if (picked) cli::col_green(cli::symbol$tick) else " "
      rl_tc_option(j, st$choices[[j]], mark)
    }
  }
  if (st$type == "review") {
    rl_tc_review(steps, answers)
  }
  if (has_current && st$type %in% c("number", "yesno")) {
    cli::cat_line("  ", cli::col_grey("Current answer: "), rl_tc_format_value(st, current))
  }
  cli::cat_line(cli::col_grey(paste0("  ", rl_tc_hint(st, has_current))))
}

# One numbered option, wrapped with a hanging indent.
#' @noRd
rl_tc_option <- function(num, label, mark = " ") {
  prefix <- paste0("  ", mark, " ", cli::col_cyan(format(num, width = 2)), ". ")
  pad <- cli::ansi_nchar(prefix)
  lines <- cli::ansi_strwrap(label, width = max(30, cli::console_width() - pad - 1))
  cli::cat_line(paste0(c(prefix, rep(strrep(" ", pad), length(lines) - 1L)), lines))
}

#' @noRd
rl_tc_review <- function(steps, answers) {
  shown <- Filter(function(s) {
    s$type != "review" && rl_tc_visible(s, answers) && !is.null(answers[[s$id]])
  }, steps)
  if (length(shown) == 0L) return(invisible())
  width <- max(nchar(vapply(shown, function(s) s$label, character(1))))
  room <- max(20, cli::console_width() - width - 5)
  for (s in shown) {
    cli::cat_line(
      "  ", cli::col_grey(formatC(s$label, width = -width)), "  ",
      cli::ansi_strtrim(rl_tc_format_value(s, answers[[s$id]]), room)
    )
  }
}

#' @noRd
rl_tc_hint <- function(st, has_current) {
  what <- switch(st$type,
    choice = "Type a number",
    multi = "Type one or more numbers, e.g. 1,3, or all",
    number = "Type a number",
    yesno = "Type y or n",
    review = "Press Enter to see the result"
  )
  optional <- isTRUE(st$optional)
  extra <- c(
    if (has_current) "Enter = keep",
    if (optional && !has_current) "Enter = unknown",
    if (optional && has_current) "na = unknown",
    "b = back", "q = quit", "? = help"
  )
  paste(c(what, extra), collapse = ": ")
}

#' @noRd
rl_tc_format_value <- function(st, v) {
  switch(st$type,
    number = if (is.na(v)) "unknown" else paste0(rl_tc_fmt(v), if (identical(st$unit, "%")) "%" else ""),
    yesno = if (is.na(v)) "unknown" else if (isTRUE(v)) "yes" else "no",
    choice = unname(st$choices[[v]]),
    multi = paste(v, collapse = ", "),
    as.character(v)
  )
}

# A coloured tag in the IUCN category colours, or a grey dash when no
# threatened category is met.
#' @noRd
rl_tc_badge <- function(category) {
  if (is.na(category)) return(cli::col_grey(" -- "))
  bg <- c(CR = "#D81E05", EN = "#FC7F3F", VU = "#F9E814")[[category]]
  fg <- if (category == "VU") "black" else "white"
  style <- cli::combine_ansi_styles(
    cli::make_ansi_style(bg, bg = TRUE), cli::make_ansi_style(fg), "bold"
  )
  style(paste0(" ", category, " "))
}


# #####################################
# Deciding the category from the answers
# ######################################

rl_tc_levels <- c("CR", "EN", "VU")

# TRUE when category `x` is at least as threatened as `level`.
#' @noRd
rl_tc_at_least <- function(x, level) {
  isTRUE(match(x, rl_tc_levels) <= match(level, rl_tc_levels))
}

# The most threatened category among `x`, or NA when there is none.
#' @noRd
rl_tc_worst <- function(x) {
  r <- match(x, rl_tc_levels)
  if (all(is.na(r))) NA_character_ else rl_tc_levels[min(r, na.rm = TRUE)]
}

#' @noRd
rl_tc_num <- function(x) {
  if (is.null(x) || length(x) != 1L) NA_real_ else as.numeric(x)
}

#' @noRd
rl_tc_fmt <- function(x) {
  format(x, big.mark = ",", scientific = FALSE, trim = TRUE)
}

#' @noRd
rl_tc_row <- function(criterion, category, code, reason) {
  list(
    criterion = criterion,
    category = as.character(category),
    code = as.character(code),
    reason = reason
  )
}

# Combine the criteria chosen in `answers$scope` into the result object.
#' @noRd
rl_tc_decide <- function(answers) {
  deciders <- list(
    A = rl_tc_crit_a, B = rl_tc_crit_b, C = rl_tc_crit_c,
    D = rl_tc_crit_d, E = rl_tc_crit_e
  )
  scope <- intersect(names(deciders), answers$scope %||% character())
  rows <- lapply(scope, function(k) deciders[[k]](answers))
  pick <- function(field) vapply(rows, function(r) r[[field]], character(1))

  details <- dplyr::tibble(
    criterion = pick("criterion"),
    category = pick("category"),
    code = pick("code"),
    reason = pick("reason")
  )

  category <- rl_tc_worst(details$category)
  criteria <- if (is.na(category)) {
    NA_character_
  } else {
    paste(details$code[details$category %in% category], collapse = "; ")
  }

  structure(
    list(category = category, criteria = criteria, details = details, answers = answers),
    class = "rl_threat_category"
  )
}

#' @noRd
rl_tc_crit_a <- function(a) {
  red <- rl_tc_num(a$a_reduction)
  sub <- a$a_basis
  if (is.na(red) || is.null(sub)) {
    return(rl_tc_row("A", NA, NA, "Not enough information."))
  }

  thr <- if (sub == "A1") c(CR = 90, EN = 70, VU = 50) else c(CR = 80, EN = 50, VU = 30)
  category <- rl_criterion_a_band(red / 100, subcriterion = if (sub == "A1") "A1" else "A2")

  if (is.na(category)) {
    reason <- sprintf(
      "%s%% reduction is below the %s threshold for VU (\u2265 %s%%).",
      rl_tc_fmt(red), sub, thr[["VU"]]
    )
    return(rl_tc_row("A", NA, NA, reason))
  }
  reason <- sprintf(
    "%s%% reduction under %s reaches %s (\u2265 %s%%).",
    rl_tc_fmt(red), sub, category, thr[[category]]
  )
  rl_tc_row("A", category, sub, reason)
}

#' @noRd
rl_tc_crit_b <- function(a) {
  eoo <- rl_tc_num(a$b_eoo)
  aoo <- rl_tc_num(a$b_aoo)
  if (is.na(eoo) && is.na(aoo)) {
    return(rl_tc_row("B", NA, NA, "No EOO or AOO was given."))
  }

  note <- NULL
  if (!is.na(eoo) && !is.na(aoo) && eoo < aoo) {
    eoo <- aoo
    note <- "EOO was raised to equal AOO."
  }

  eoo_thr <- c(CR = 100, EN = 5000, VU = 20000)
  aoo_thr <- c(CR = 10, EN = 500, VU = 2000)
  loc_thr <- c(CR = 1, EN = 5, VU = 10)
  b1 <- rl_b1_category(eoo)
  b2 <- rl_b2_category(aoo)
  loc <- rl_tc_num(a$b_locations)

  for (lv in rl_tc_levels) {
    r1 <- rl_tc_at_least(b1, lv)
    r2 <- rl_tc_at_least(b2, lv)
    if (!r1 && !r2) next

    met <- c(
      a = isTRUE(a$b_fragmented) || (!is.na(loc) && loc <= loc_thr[[lv]]),
      b = isTRUE(a$b_decline),
      c = isTRUE(a$b_fluct)
    )
    if (sum(met) < 2L) next

    conds <- paste(names(met)[met], collapse = "")
    code <- paste0("B", paste(c(if (r1) paste0("1", conds), if (r2) paste0("2", conds)), collapse = "+"))
    range <- c(
      if (r1) sprintf("EOO %s km\u00b2 < %s", rl_tc_fmt(eoo), rl_tc_fmt(eoo_thr[[lv]])),
      if (r2) sprintf("AOO %s km\u00b2 < %s", rl_tc_fmt(aoo), rl_tc_fmt(aoo_thr[[lv]]))
    )
    reason <- paste(
      c(sprintf(
        "%s, with conditions %s.",
        paste(range, collapse = " and "), paste(names(met)[met], collapse = ", ")
      ), note),
      collapse = " "
    )
    return(rl_tc_row("B", lv, code, reason))
  }

  best <- rl_tc_worst(c(b1, b2))
  reason <- if (is.na(best)) {
    "EOO and AOO are above the thresholds for VU (20,000 and 2,000 km\u00b2)."
  } else {
    sprintf(
      "The range reaches the %s threshold, but fewer than two of conditions a, b and c are met.",
      best
    )
  }
  rl_tc_row("B", NA, NA, paste(c(reason, note), collapse = " "))
}

#' @noRd
rl_tc_crit_c <- function(a) {
  n <- rl_tc_num(a$mature)
  if (is.na(n)) {
    return(rl_tc_row("C", NA, NA, "The number of mature individuals is unknown."))
  }

  n_thr <- c(CR = 250, EN = 2500, VU = 10000)
  if (n >= n_thr[["VU"]]) {
    reason <- sprintf("%s mature individuals is not below 10,000 (VU).", rl_tc_fmt(n))
    return(rl_tc_row("C", NA, NA, reason))
  }

  sub_thr <- c(CR = 50, EN = 250, VU = 1000)
  pct_thr <- c(CR = 90, EN = 95, VU = 100)
  sub <- rl_tc_num(a$c2_subpop)
  pct <- rl_tc_num(a$c2_pct)
  c2 <- isTRUE(a$c2_decline)

  for (lv in rl_tc_levels) {
    if (n >= n_thr[[lv]]) next

    c1 <- rl_tc_at_least(a$c1_rate, lv)
    ai <- c2 && !is.na(sub) && sub <= sub_thr[[lv]]
    aii <- c2 && !is.na(pct) && pct >= pct_thr[[lv]]
    cb <- c2 && isTRUE(a$c2_fluct)
    if (!(c1 || ai || aii || cb)) next

    roman <- c(if (ai) "i", if (aii) "ii")
    c2code <- paste(c(
      if (length(roman)) paste0("a(", paste(roman, collapse = ","), ")"),
      if (cb) "b"
    ), collapse = "")
    code <- paste0("C", paste(c(if (c1) "1", if (nzchar(c2code)) paste0("2", c2code)), collapse = "+"))
    with <- c(if (c1) "a C1 decline", if (nzchar(c2code)) paste0("C2", c2code))
    reason <- sprintf(
      "%s mature individuals < %s, with %s.",
      rl_tc_fmt(n), rl_tc_fmt(n_thr[[lv]]), paste(with, collapse = " and ")
    )
    return(rl_tc_row("C", lv, code, reason))
  }

  reason <- sprintf(
    "%s mature individuals is below 10,000, but neither C1 nor C2 is met.",
    rl_tc_fmt(n)
  )
  rl_tc_row("C", NA, NA, reason)
}

#' @noRd
rl_tc_crit_d <- function(a) {
  n <- rl_tc_num(a$mature)
  d2 <- isTRUE(a$d2)
  d1 <- if (is.na(n)) {
    NA_character_
  } else if (n < 50) {
    "CR"
  } else if (n < 250) {
    "EN"
  } else if (n < 1000) {
    "VU"
  } else {
    NA_character_
  }

  category <- rl_tc_worst(c(d1, if (d2) "VU"))
  if (is.na(category)) {
    reason <- if (is.na(n)) {
      "The number of mature individuals is unknown, and D2 does not apply."
    } else {
      sprintf("%s mature individuals is not below 1,000, and D2 does not apply.", rl_tc_fmt(n))
    }
    return(rl_tc_row("D", NA, NA, reason))
  }

  if (category %in% c("CR", "EN")) {
    d_thr <- c(CR = 50, EN = 250)
    reason <- sprintf("%s mature individuals < %s.", rl_tc_fmt(n), rl_tc_fmt(d_thr[[category]]))
    return(rl_tc_row("D", category, "D", reason))
  }

  vu1 <- identical(d1, "VU")
  code <- paste0("D", paste(c(if (vu1) "1", if (d2) "2"), collapse = "+"))
  reason <- paste(c(
    if (vu1) sprintf("%s mature individuals < 1,000", rl_tc_fmt(n)),
    if (d2) "a restricted range facing a plausible, fast-acting threat (D2)"
  ), collapse = " and ")
  rl_tc_row("D", "VU", code, paste0(toupper(substr(reason, 1, 1)), substring(reason, 2), "."))
}

#' @noRd
rl_tc_crit_e <- function(a) {
  p <- a$e_prob
  if (is.null(p) || !p %in% rl_tc_levels) {
    return(rl_tc_row("E", NA, NA, "The probability of extinction reaches none of the thresholds."))
  }
  desc <- c(
    CR = "\u2265 50% within 10 years or 3 generations",
    EN = "\u2265 20% within 20 years or 5 generations",
    VU = "\u2265 10% within 100 years"
  )
  rl_tc_row("E", p, "E", sprintf("Probability of extinction %s.", desc[[p]]))
}
