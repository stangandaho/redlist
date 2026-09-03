#' Population reduction for IUCN criterion A
#'
#' Estimate the population reduction of a taxon over the most recent three
#' generations (or ten years, whichever is longer), following section 4.5 of the
#' IUCN Red List guidelines. A decline model is fitted to the population
#' estimates and used to read off the population size at the start and end of the
#' window, and the reduction is the proportional drop between them. The same
#' calculation gives the estimated continuing decline of criterion C1 and B when
#' a different window is set through `years`.
#'
#' @details
#' Two decline patterns are supported.
#' \describe{
#'   \item{`"exponential"`}{a constant proportional rate of decline, fitted as a
#'     log-linear regression of population size on time. Appropriate when the
#'     rate of loss stays proportional to population size, for example a constant
#'     harvest fraction.}
#'   \item{`"linear"`}{a constant number of individuals lost per year, fitted as
#'     a linear regression of population size on time. Appropriate when a fixed
#'     amount is removed each year, for example a fixed area of habitat lost.}
#' }
#' With exactly two estimates the fit passes through both points, reproducing the
#' two-point formulas in the guidelines. With more estimates the regression
#' smooths natural variation, and the reduction is still read over the most
#' recent window.
#'
#' The `category_a` column reports the most threatened band the reduction reaches
#' for the chosen subcriterion, or `NA` when it reaches none (including an
#' increase). The criterion A thresholds are 50/70/90 percent (VU/EN/CR) for
#' `"A1"` and 30/50/80 percent for `"A2"`, `"A3"` and `"A4"`. This is the
#' magnitude threshold only, not a full assessment.
#'
#' @param population Numeric vector of population sizes (number of mature
#'   individuals, or an index that scales with it).
#' @param time Numeric vector of the years the sizes refer to, the same length
#'   as `population`.
#' @param generation_length Generation length in years. See
#'   [rl_generation_length()].
#' @param model Decline pattern, `"exponential"` (default) or `"linear"`.
#' @param assessment_year The year taken as the present. Default is the most
#'   recent year in `time`.
#' @param years Length of the assessment window in years. Default is the longer
#'   of three generations or ten years.
#' @param subcriterion Which criterion A subcriterion sets the thresholds for
#'   `category_a`: `"A2"` (default), `"A1"`, `"A3"` or `"A4"`.
#'
#' @return A one row tibble with the model and window used, the fitted population
#'   sizes at the start and end of the window (`n_start`, `n_present`), the
#'   `reduction` (a proportion) and `reduction_pct`, and `category_a`.
#'
#' @references
#' IUCN Standards and Petitions Committee. 2024. Guidelines for Using the IUCN
#' Red List Categories and Criteria. Version 16, section 4.5.
#' \url{https://www.iucnredlist.org/documents/RedListGuidelines.pdf}
#'
#' @seealso [rl_overall_reduction()], [rl_generation_length()]
#'
#' @examples
#' # Guidelines example: 20000 in 1961 and 14000 in 1981, generation length 20,
#' # assessed in 2001 so the three generation window runs 1941 to 2001.
#' # Exponential decline gives a 65.7 percent reduction.
#' rl_reduction(population = c(20000, 14000), time = c(1961, 1981),
#'              generation_length = 20, model = "exponential",
#'              assessment_year = 2001)
#'
#' # The same data under a linear decline gives 69.2 percent.
#' rl_reduction(population = c(20000, 14000), time = c(1961, 1981),
#'              generation_length = 20, model = "linear",
#'              assessment_year = 2001)
#' @export
rl_reduction <- function(population, time, generation_length,
                         model = c("exponential", "linear"),
                         assessment_year = NULL,
                         years = NULL,
                         subcriterion = c("A2", "A1", "A3", "A4")) {
  model <- match.arg(model)
  subcriterion <- match.arg(subcriterion)

  if (length(population) != length(time)) {
    cli::cli_abort("{.arg population} and {.arg time} must have the same length.")
  }
  if (length(population) < 2) {
    cli::cli_abort("At least two population estimates are needed.")
  }
  if (generation_length <= 0) {
    cli::cli_abort("{.arg generation_length} must be positive.")
  }
  if (model == "exponential" && any(population <= 0)) {
    cli::cli_abort("Exponential decline needs positive population sizes; use {.code model = \"linear\"} for zeros.")
  }

  ord <- order(time)
  time <- time[ord]
  population <- population[ord]

  present <- assessment_year %||% max(time)
  window <- years %||% max(3 * generation_length, 10)
  start <- present - window

  # Fit the decline and read the endpoints of the window off the fitted line.
  y <- if (model == "exponential") log(population) else population
  fit <- stats::lm(y ~ time)
  coefs <- stats::coef(fit)
  a <- unname(coefs[1])
  b <- unname(coefs[2])
  hs <- a + b * start
  hp <- a + b * present

  if (model == "exponential") {
    n_start <- exp(hs)
    n_present <- exp(hp)
  } else {
    n_start <- hs
    n_present <- max(0, hp)
  }

  reduction <- 1 - n_present / n_start

  dplyr::tibble(
    model = model,
    subcriterion = subcriterion,
    generation_length = generation_length,
    window_years = window,
    year_start = start,
    year_present = present,
    n_start = n_start,
    n_present = n_present,
    reduction = reduction,
    reduction_pct = 100 * reduction,
    category_a = rl_criterion_a_band(reduction, subcriterion)
  )
}


#' Overall reduction across subpopulations for IUCN criterion A
#'
#' Combine the reductions of several subpopulations into one reduction for the
#' taxon, following section 4.5.4 of the IUCN Red List guidelines. The overall
#' reduction is the change in the summed population, which equals the average of
#' the subpopulation reductions weighted by their size three generations ago.
#'
#' Give any two of `past`, `present` and `reduction` for each subpopulation and
#' the third is worked out from `reduction = 1 - present / past`. The sizes
#' should already be projected to the start and end of the same window, for
#' example with [rl_reduction()].
#'
#' @param past Numeric vector of subpopulation sizes at the start of the window
#'   (three generations ago).
#' @param present Numeric vector of subpopulation sizes at the end of the window.
#' @param reduction Numeric vector of subpopulation reductions (proportions).
#' @param subpopulation Optional labels for the subpopulations.
#' @param subcriterion Which criterion A subcriterion sets the thresholds for
#'   `category_a`: `"A2"` (default), `"A1"`, `"A3"` or `"A4"`.
#'
#' @return A one row tibble with the overall `reduction` and `reduction_pct`, the
#'   number of subpopulations, the summed past and present sizes, and
#'   `category_a`. The per-subpopulation table is attached as the
#'   `"subpopulations"` attribute.
#'
#' @references
#' IUCN Standards and Petitions Committee. 2024. Guidelines for Using the IUCN
#' Red List Categories and Criteria. Version 16, section 4.5.4.
#'
#' @seealso [rl_reduction()]
#'
#' @examples
#' # Guidelines Example 1: past and present sizes for three subpopulations
#' rl_overall_reduction(
#'   past = c(10000, 8000, 12000),
#'   present = c(5000, 9000, 2000),
#'   subpopulation = c("Pacific", "Atlantic", "Indian")
#' )
#' @export
rl_overall_reduction <- function(past = NULL, present = NULL, reduction = NULL,
                                 subpopulation = NULL,
                                 subcriterion = c("A2", "A1", "A3", "A4")) {
  subcriterion <- match.arg(subcriterion)

  given <- c(past = !is.null(past), present = !is.null(present),
             reduction = !is.null(reduction))
  if (sum(given) < 2) {
    cli::cli_abort("Provide at least two of {.arg past}, {.arg present} and {.arg reduction}.")
  }

  if (is.null(reduction)) reduction <- 1 - present / past
  if (is.null(past)) past <- present / (1 - reduction)
  if (is.null(present)) present <- past * (1 - reduction)

  if (any(past <= 0)) {
    cli::cli_abort("Past subpopulation sizes must be positive.")
  }

  overall <- 1 - sum(present) / sum(past)

  per <- dplyr::tibble(
    subpopulation = subpopulation %||% seq_along(past),
    past = past,
    present = present,
    reduction = 1 - present / past,
    weight = past / sum(past)
  )

  out <- dplyr::tibble(
    reduction = overall,
    reduction_pct = 100 * overall,
    n_subpop = length(past),
    past_total = sum(past),
    present_total = sum(present),
    category_a = rl_criterion_a_band(overall, subcriterion)
  )
  attr(out, "subpopulations") <- per
  out
}


# IUCN criterion A reduction thresholds, as proportions.
# A1 (reversible, understood and ceased) is stricter than A2 to A4.
#' @noRd
rl_criterion_a_band <- function(reduction, subcriterion = "A2") {
  if (is.na(reduction)) return(NA_character_)
  thr <- if (subcriterion == "A1") c(0.9, 0.7, 0.5) else c(0.8, 0.5, 0.3)
  if (reduction >= thr[1]) {
    "CR"
  } else if (reduction >= thr[2]) {
    "EN"
  } else if (reduction >= thr[3]) {
    "VU"
  } else {
    NA_character_
  }
}
