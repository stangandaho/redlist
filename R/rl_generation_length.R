#' Generation length for IUCN Red List assessments
#'
#' Compute generation length, the average age of reproducing individuals in a
#' population, using one of the four definitions given in the IUCN Red List
#' guidance. Generation length sets the time window used by criteria A and C.
#'
#' @details
#' Each method needs different input columns. Pass the relevant columns unquoted
#' (tidy-style); only the columns a method actually uses need to be present.
#'
#' \describe{
#'   \item{`"mean_parent"` (mean age of parents)}{
#'     One row per newborn, holding the age of its parent when the newborn was
#'     produced. Generation length is the mean parental age. If the population is
#'     **not** at a stable age distribution, supply `year`: the mean is then
#'     taken within each year and averaged across years. Columns: `age`
#'     (required), `year` (optional).}
#'
#'   \item{`"mean_reproduction"` (mean age of reproduction)}{
#'     Two input shapes are accepted:
#'     \itemize{
#'       \item event form: one cohort followed over life, one row per breeding
#'             event with the age at which it happened. Generation length is the
#'             mean of those ages. Columns: `age`.
#'       \item life-table form: one row per age with survivorship `lx` and
#'             age-specific fecundity `mx`. Generation length is the weighted
#'             mean age of reproduction sum(x * lx * mx) / sum(lx * mx), which
#'             reproduces the result of the official IUCN generation length
#'             calculator. Columns: `age`, `lx`, `mx`.
#'     }
#'     Supply `lx` and `mx` to use the life-table form; omit both for the event
#'     form.}
#'
#'   \item{`"half_reproduction"` (50% of reproductive output)}{
#'     Age at which an individual reaches half of its lifetime reproductive
#'     output, averaged over individuals. Output is measured in offspring
#'     produced; supply that as `output`. A count of breeding events works as a
#'     proxy when every event yields the same number of offspring. Two input
#'     shapes are accepted:
#'     \itemize{
#'       \item event form: one row per breeding event with an `age` column (and
#'             `id` to separate individuals); each row counts as one unit of
#'             output when `output` is not supplied;
#'       \item summarised form: one row per (`id`, `age`) with an `output` column
#'             giving the offspring produced at that age.
#'     }
#'     The 50% age is the weighted median age: the smallest age at which the
#'     running total of output reaches half of the individual's lifetime total.
#'     Reproductive output happens *at* an age, so no value between age classes
#'     is invented. Columns: `age` (required), `id` (required with more than one
#'     individual), `output` (optional; omit for the one-event-per-row form).}
#'
#'   \item{`"replacement"` (replacement rate)}{
#'     Time for the population to grow by its net reproductive rate
#'     R0 = sum(lx * mx). With intrinsic growth rate `r` the population multiplies
#'     by exp(r * t) each unit of time, so T = log(R0) / r, where `r` solves the
#'     Euler-Lotka equation sum(exp(-r * x) * lx * mx) = 1. When the population is
#'     essentially stationary (R0 close to 1, r close to 0) the limit is the mean
#'     age of reproduction sum(x * lx * mx) / sum(lx * mx), which is returned
#'     instead. Columns: `age`, `lx`, `mx` (all required).}
#' }
#'
#' @param data A data frame or tibble holding the columns the chosen `method`
#'   needs.
#' @param method One of `"mean_parent"`, `"mean_reproduction"`,
#'   `"half_reproduction"`, `"replacement"`.
#' @param age Column of ages,
#'   unquoted. Used by every method (as `x` in `replacement`).
#' @param year Optional grouping
#'   column for `mean_parent` when the population is not at a stable age
#'   distribution. Unquoted.
#' @param id Optional individual
#'   identifier for `half_reproduction`. Unquoted.
#' @param output Reproductive
#'   output at each `age` for `half_reproduction`: offspring produced, or a count
#'   of breeding events as a proxy. If omitted, each row counts as one unit of
#'   output. Unquoted.
#' @param lx,mx Survivorship and
#'   age-specific fecundity columns, unquoted. Required for `method =
#'   "replacement"`, and for the life-table form of `method =
#'   "mean_reproduction"`.
#' @param na_rm Logical; drop missing values before computing. Default `TRUE`.
#'
#' @return A single numeric value: the generation length.
#'
#' @references
#' IUCN Standards and Petitions Committee. 2024. Guidelines for Using the IUCN
#' Red List Categories and Criteria. Version 16. Prepared by the Standards and
#' Petitions Committee. Pages 30-32.
#' \url{https://www.iucnredlist.org/documents/RedListGuidelines.pdf}
#'
#' @examples
#' # Mean age of parents at a stable age distribution
#' parents <- data.frame(age = c(5, 5, 3, 3, 4, 6, 6, 4, 5))
#' rl_generation_length(parents, "mean_parent", age = age)
#'
#' # Mean age of reproduction for one cohort
#' cohort <- data.frame(age_of_breeding = c(5, 5, 3, 8, 5, 6, 3, 8, 9, 4))
#' rl_generation_length(cohort, "mean_reproduction", age = age_of_breeding)
#'
#' # Same definition from a life table, reproducing the official IUCN
#' # calculator (this input returns 10.5, as the IUCN workbook does)
#' # https://www.iucnredlist.org/resources/generation-length-calculator
#' life_table <- data.frame(
#'   age = 0:19,
#'   lx = c(1, 0.1, rep(0.01, 17), 0),
#'   mx = c(0, 0, 0, rep(30, 16), 0)
#' )
#' rl_generation_length(life_table, "mean_reproduction", age = age, lx = lx, mx = mx)
#'
#' # 50% of reproductive output, several mothers, weighted by breeding counts
#' rep_data <- data.frame(
#'   mother = rep(c("m1", "m2"), each = 3),
#'   age = c(2, 3, 4, 2, 3, 4),
#'   n_offspring = c(2, 3, 2, 2, 2, 2)
#' )
#' rl_generation_length(rep_data, "half_reproduction",
#'                      age = age, id = mother, output = n_offspring)
#'
#' # Replacement rate from a life table
#' life_table <- data.frame(
#'   age = 1:4,
#'   lx = c(1, 0.6, 0.3, 0.1),
#'   mx = c(0, 1.5, 2, 1)
#' )
#' rl_generation_length(life_table, "replacement", age = age, lx = lx, mx = mx)
#'
#' @importFrom rlang enquo quo_is_null as_name
#' @export
rl_generation_length <- function(data,
                                 method = c("mean_parent", "mean_reproduction",
                                            "half_reproduction", "replacement"),
                                 age = NULL,
                                 year = NULL,
                                 id = NULL,
                                 output = NULL,
                                 lx = NULL,
                                 mx = NULL,
                                 na_rm = TRUE) {

  method <- rlang::arg_match(method, c("mean_parent", "mean_reproduction",
                                        "half_reproduction", "replacement"))

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame or tibble, not {.obj_type_friendly {data}}.")
  }

  age_q <- rlang::enquo(age)
  year_q <- rlang::enquo(year)
  id_q <- rlang::enquo(id)
  output_q <- rlang::enquo(output)
  lx_q <- rlang::enquo(lx)
  mx_q <- rlang::enquo(mx)

  # Pull a column vector from an unquoted argument, with a clear error if the
  # argument is missing or the column is absent.
  pull_col <- function(quo, arg) {
    if (rlang::quo_is_null(quo)) {
      cli::cli_abort(c(
        "{.arg {arg}} must be supplied for {.code method = {.val {method}}}.",
        i = "Pass the column name unquoted, e.g. {.code {arg} = my_column}."
      ))
    }
    nm <- rlang::as_name(quo)
    if (!nm %in% names(data)) {
      cli::cli_abort("Column {.val {nm}} was not found in {.arg data}.")
    }
    data[[nm]]
  }

  out <- switch(method,

    mean_parent = {
      a <- pull_col(age_q, "age")
      if (rlang::quo_is_null(year_q)) {
        mean(a, na.rm = na_rm)
      } else {
        yr <- pull_col(year_q, "year")
        yearly <- tapply(a, yr, function(v) mean(v, na.rm = na_rm))
        mean(yearly, na.rm = na_rm)
      }
    },

    mean_reproduction = {
      has_lx <- !rlang::quo_is_null(lx_q)
      has_mx <- !rlang::quo_is_null(mx_q)
      if (has_lx != has_mx) {
        cli::cli_abort("Supply both {.arg lx} and {.arg mx} for the life-table form, or neither.")
      }
      if (has_lx) {
        # Life-table form: mean age of reproduction as the official IUCN
        # calculator does it, sum(x * lx * mx) / sum(lx * mx).
        x <- pull_col(age_q, "age")
        lxv <- pull_col(lx_q, "lx")
        mxv <- pull_col(mx_q, "mx")
        if (na_rm) {
          keep <- !(is.na(x) | is.na(lxv) | is.na(mxv))
          x <- x[keep]; lxv <- lxv[keep]; mxv <- mxv[keep]
        }
        denom <- sum(lxv * mxv)
        if (denom <= 0) {
          cli::cli_abort("{.code sum(lx * mx)} is not positive; cannot compute generation length.")
        }
        sum(x * lxv * mxv) / denom
      } else {
        a <- pull_col(age_q, "age")
        mean(a, na.rm = na_rm)
      }
    },

    half_reproduction = {
      a <- pull_col(age_q, "age")
      w <- if (rlang::quo_is_null(output_q)) rep(1, length(a)) else pull_col(output_q, "output")
      grp <- if (rlang::quo_is_null(id_q)) rep(1L, length(a)) else pull_col(id_q, "id")

      if (na_rm) {
        keep <- !(is.na(a) | is.na(w) | is.na(grp))
        a <- a[keep]; w <- w[keep]; grp <- grp[keep]
      }
      if (length(a) == 0) {
        cli::cli_abort("No non-missing rows left to compute {.code half_reproduction}.")
      }

      per_ind <- vapply(split(data.frame(age = a, w = w), grp),
                        function(d) .weighted_median_age(d$age, d$w),
                        numeric(1))
      mean(per_ind, na.rm = TRUE)
    },

    replacement = {
      x <- pull_col(age_q, "age")
      lxv <- pull_col(lx_q, "lx")
      mxv <- pull_col(mx_q, "mx")
      if (na_rm) {
        keep <- !(is.na(x) | is.na(lxv) | is.na(mxv))
        x <- x[keep]; lxv <- lxv[keep]; mxv <- mxv[keep]
      }
      .replacement_time(x, lxv, mxv)
    }
  )

  as.numeric(out)
}


#' Weighted median age of reproductive output
#'
#' Given ages and the output produced at each age, return the smallest age at
#' which the running total of output reaches half of the lifetime total. Output
#' is treated as occurring at its age, so no value is interpolated between age
#' classes.
#'
#' @param age Numeric vector of ages.
#' @param w Numeric vector of output (offspring or breeding events) per age.
#' @return A single numeric age.
#' @keywords internal
#' @noRd
.weighted_median_age <- function(age, w) {
  ag <- tapply(w, age, sum)
  ages <- as.numeric(names(ag))
  wts <- as.numeric(ag)

  total <- sum(wts)
  if (total <= 0) {
    return(NA_real_)
  }
  ages[which(cumsum(wts) >= total / 2)[1]]
}


#' Generation time from the replacement rate
#'
#' Solve the Euler-Lotka equation for the intrinsic growth rate `r`, then return
#' T = log(R0) / r with R0 = sum(lx * mx). Near a stationary population the ratio
#' is indeterminate, so the mean age of reproduction is returned as the limit.
#'
#' @param x Numeric vector of ages.
#' @param lx Numeric vector of survivorship to each age.
#' @param mx Numeric vector of age-specific fecundity.
#' @return A single numeric generation time.
#' @keywords internal
#' @noRd
.replacement_time <- function(x, lx, mx) {
  r0 <- sum(lx * mx)
  if (r0 <= 0) {
    cli::cli_abort("Net reproductive rate {.code sum(lx * mx)} is not positive; cannot compute generation time.")
  }

  mean_age <- sum(x * lx * mx) / r0

  # A stationary population (R0 close to 1) gives r close to 0 and log(R0) / r
  # becomes 0/0; the limit is the mean age of reproduction.
  if (isTRUE(all.equal(r0, 1))) {
    return(mean_age)
  }

  euler_lotka <- function(r) sum(exp(-r * x) * lx * mx) - 1
  r <- stats::uniroot(euler_lotka, interval = c(-2, 2), extendInt = "downX")$root

  if (abs(r) < 1e-8) mean_age else log(r0) / r
}
