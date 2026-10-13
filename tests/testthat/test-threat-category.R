# Feed a fixed sequence of answers to the prompts.
fake_reader <- function(inputs) {
  i <- 0L
  function(prompt) {
    i <<- i + 1L
    if (i > length(inputs)) stop("The test ran out of answers.")
    inputs[[i]]
  }
}

# Run the form without printing anything.
quiet <- function(expr) {
  op <- options(cli.default_handler = function(msg) invisible(NULL))
  on.exit(options(op), add = TRUE)
  out <- NULL
  utils::capture.output(out <- expr)
  out
}

test_that("criterion A uses the A1 or the A2 to A4 thresholds", {
  a2 <- rl_tc_decide(list(scope = "A", a_basis = "A2", a_reduction = 65.7))
  expect_equal(a2$category, "EN")
  expect_equal(a2$criteria, "A2")

  a1 <- rl_tc_decide(list(scope = "A", a_basis = "A1", a_reduction = 65.7))
  expect_equal(a1$category, "VU")
  expect_equal(a1$criteria, "A1")

  expect_equal(rl_tc_decide(list(scope = "A", a_basis = "A3", a_reduction = 30))$category, "VU")
  expect_true(is.na(rl_tc_decide(list(scope = "A", a_basis = "A4", a_reduction = 20))$category))
})

test_that("criterion B needs a range threshold and two of conditions a, b, c", {
  # EOO is below the CR threshold, but 3 locations only meet condition (a) for EN.
  r <- rl_tc_decide(list(
    scope = "B", b_eoo = 80, b_aoo = NA, b_fragmented = FALSE,
    b_locations = 3, b_decline = TRUE, b_fluct = FALSE
  ))
  expect_equal(r$category, "EN")
  expect_equal(r$criteria, "B1ab")

  one_condition <- rl_tc_decide(list(
    scope = "B", b_eoo = 80, b_aoo = NA, b_fragmented = FALSE,
    b_locations = NA, b_decline = TRUE, b_fluct = FALSE
  ))
  expect_true(is.na(one_condition$category))

  both <- rl_tc_decide(list(
    scope = "B", b_eoo = 4000, b_aoo = 300, b_fragmented = TRUE,
    b_locations = NA, b_decline = TRUE, b_fluct = NA
  ))
  expect_equal(both$category, "EN")
  expect_equal(both$criteria, "B1ab+2ab")

  expect_true(is.na(rl_tc_decide(list(scope = "B", b_eoo = NA, b_aoo = NA))$category))
})

test_that("an EOO smaller than the AOO is raised to the AOO", {
  r <- rl_tc_decide(list(
    scope = "B", b_eoo = 50, b_aoo = 120, b_fragmented = TRUE, b_decline = TRUE
  ))
  # Left at 50 km2 the EOO would reach CR; raised to 120 km2 it reaches EN.
  expect_equal(r$category, "EN")
  expect_equal(r$criteria, "B1ab+2ab")
  expect_match(r$details$reason, "raised")
})

test_that("criterion C combines population size with C1 or C2", {
  c1 <- rl_tc_decide(list(scope = "C", mature = 2000, c1_rate = "EN", c2_decline = FALSE))
  expect_equal(c1$category, "EN")
  expect_equal(c1$criteria, "C1")

  # A CR-level decline cannot lift the category above what the count allows.
  capped <- rl_tc_decide(list(scope = "C", mature = 2000, c1_rate = "CR", c2_decline = FALSE))
  expect_equal(capped$category, "EN")

  c2ai <- rl_tc_decide(list(
    scope = "C", mature = 200, c1_rate = "none", c2_decline = TRUE,
    c2_subpop = 40, c2_pct = NA, c2_fluct = FALSE
  ))
  expect_equal(c2ai$category, "CR")
  expect_equal(c2ai$criteria, "C2a(i)")

  c2aii <- rl_tc_decide(list(
    scope = "C", mature = 2000, c1_rate = "none", c2_decline = TRUE,
    c2_subpop = NA, c2_pct = 96, c2_fluct = FALSE
  ))
  expect_equal(c2aii$category, "EN")
  expect_equal(c2aii$criteria, "C2a(ii)")

  expect_true(is.na(rl_tc_decide(list(scope = "C", mature = 20000))$category))
  expect_true(is.na(rl_tc_decide(list(
    scope = "C", mature = 500, c1_rate = "none", c2_decline = FALSE
  ))$category))
})

test_that("criterion D uses the D1 thresholds and D2 for VU only", {
  cr <- rl_tc_decide(list(scope = "D", mature = 40))
  expect_equal(cr$category, "CR")
  expect_equal(cr$criteria, "D")

  expect_equal(rl_tc_decide(list(scope = "D", mature = 600, d2 = TRUE))$criteria, "D1+2")
  expect_equal(rl_tc_decide(list(scope = "D", mature = 5000, d2 = TRUE))$criteria, "D2")
  expect_true(is.na(rl_tc_decide(list(scope = "D", mature = 5000, d2 = FALSE))$category))
})

test_that("criterion E reads the chosen probability bracket", {
  expect_equal(rl_tc_decide(list(scope = "E", e_prob = "CR"))$category, "CR")
  expect_true(is.na(rl_tc_decide(list(scope = "E", e_prob = "none"))$category))
})

test_that("the overall category is the most threatened one met", {
  r <- rl_tc_decide(list(
    scope = c("A", "D", "E"), a_basis = "A2", a_reduction = 35,
    mature = 200, d2 = NA, e_prob = "EN"
  ))
  expect_equal(r$category, "EN")
  expect_equal(r$criteria, "D; E")
  expect_equal(nrow(r$details), 3)
  expect_equal(r$details$category, c("VU", "EN", "EN"))
})

test_that("number answers accept spaces, refuse commas and check whole numbers", {
  st <- list(type = "number", min = 0, integer = TRUE)
  expect_equal(rl_tc_parse(st, "20 000")$value, 20000)
  expect_match(rl_tc_parse(st, "20,000")$error, "commas")
  expect_match(rl_tc_parse(st, "12.5")$error, "whole")
  expect_match(rl_tc_parse(st, "abc")$error, "not a number")
  expect_match(rl_tc_parse(st, "")$error, "needed")
  expect_true(is.na(rl_tc_parse(utils::modifyList(st, list(optional = TRUE)), "")$value))
})

test_that("choices are picked by number, and all selects every option", {
  st <- list(type = "multi", choices = c(A = "a", B = "b", C = "c"))
  expect_equal(rl_tc_parse(st, "3, 1")$value, c("A", "C"))
  expect_equal(rl_tc_parse(st, "all")$value, c("A", "B", "C"))
  expect_match(rl_tc_parse(st, "4")$error, "between 1 and 3")
})

test_that("the form can go back, keep answers, and re-ask after bad input", {
  # scope A, A2, 10%, back from the review, change to 60%, see the result
  ans <- quiet(rl_tc_run(rl_tc_steps(), read = fake_reader(c("1", "2", "10", "b", "60", ""))))
  expect_equal(ans$scope, "A")
  expect_equal(ans$a_basis, "A2")
  expect_equal(ans$a_reduction, 60)
  expect_null(ans$review)

  # Bad answers are asked again; Enter keeps the current value after going back.
  ans <- quiet(rl_tc_run(
    rl_tc_steps(),
    read = fake_reader(c("9", "1", "2", "abc", "150", "45", "b", "", ""))
  ))
  expect_equal(ans$a_reduction, 45)
  expect_equal(rl_tc_decide(ans)$category, "VU")
})

test_that("changing the criteria drops the answers of hidden questions", {
  # Answer A, go back to the first question and switch to E only.
  ans <- quiet(rl_tc_run(
    rl_tc_steps(),
    read = fake_reader(c("1", "2", "60", "b", "b", "b", "5", "4", ""))
  ))
  expect_equal(ans$scope, "E")
  expect_null(ans$a_basis)
  expect_null(ans$a_reduction)
  expect_equal(ans$e_prob, "CR")
})

test_that("the question total counts every question of the chosen criteria", {
  steps <- rl_tc_steps()
  n_planned <- function(scope) {
    sum(vapply(steps, rl_tc_planned, logical(1), answers = list(scope = scope)))
  }
  # scope + 2 (A) + 6 (B) + review, even before B's conditions are shown
  expect_equal(n_planned(c("A", "B")), 10)
  # scope + mature individuals + d2 + review
  expect_equal(n_planned("D"), 4)
})

test_that("quitting returns NULL", {
  expect_null(quiet(rl_tc_run(rl_tc_steps(), read = fake_reader("q"))))
})

test_that("rl_threat_category() needs an interactive session", {
  rlang::local_interactive(FALSE)
  expect_error(rl_threat_category(), "interactive")
})

test_that("rl_threat_category() runs end to end and prints a report", {
  rlang::local_interactive(TRUE)
  # criterion D, 40 mature individuals, D2 unknown, see the result
  local_mocked_bindings(rl_tc_read = fake_reader(c("4", "40", "", "")))
  res <- quiet(rl_threat_category())

  expect_s3_class(res, "rl_threat_category")
  expect_equal(res$category, "CR")
  expect_equal(res$criteria, "D")

  out <- cli::cli_fmt(print(res))
  expect_true(any(grepl("Critically Endangered", out)))
})
