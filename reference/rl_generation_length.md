# Generation length for IUCN Red List assessments

Compute generation length, the average age of reproducing individuals in
a population, using one of the four definitions given in the IUCN Red
List guidance. Generation length sets the time window used by criteria A
and C.

## Usage

``` r
rl_generation_length(
  data,
  method = c("mean_parent", "mean_reproduction", "half_reproduction", "replacement"),
  age = NULL,
  year = NULL,
  id = NULL,
  output = NULL,
  lx = NULL,
  mx = NULL,
  na_rm = TRUE
)
```

## Arguments

- data:

  A data frame or tibble holding the columns the chosen `method` needs.

- method:

  One of `"mean_parent"`, `"mean_reproduction"`, `"half_reproduction"`,
  `"replacement"`.

- age:

  Column of ages, unquoted. Used by every method (as `x` in
  `replacement`).

- year:

  Optional grouping column for `mean_parent` when the population is not
  at a stable age distribution. Unquoted.

- id:

  Optional individual identifier for `half_reproduction`. Unquoted.

- output:

  Reproductive output at each `age` for `half_reproduction`: offspring
  produced, or a count of breeding events as a proxy. If omitted, each
  row counts as one unit of output. Unquoted.

- lx, mx:

  Survivorship and age-specific fecundity columns, unquoted. Required
  for `method = "replacement"`, and for the life-table form of
  `method = "mean_reproduction"`.

- na_rm:

  Logical; drop missing values before computing. Default `TRUE`.

## Value

A single numeric value: the generation length.

## Details

Each method needs different input columns. Pass the relevant columns
unquoted (tidy-style); only the columns a method actually uses need to
be present.

- `"mean_parent"` (mean age of parents):

  One row per newborn, holding the age of its parent when the newborn
  was produced. Generation length is the mean parental age. If the
  population is **not** at a stable age distribution, supply `year`: the
  mean is then taken within each year and averaged across years.
  Columns: `age` (required), `year` (optional).

- `"mean_reproduction"` (mean age of reproduction):

  Two input shapes are accepted:

  - event form: one cohort followed over life, one row per breeding
    event with the age at which it happened. Generation length is the
    mean of those ages. Columns: `age`.

  - life-table form: one row per age with survivorship `lx` and
    age-specific fecundity `mx`. Generation length is the weighted mean
    age of reproduction sum(x \* lx \* mx) / sum(lx \* mx), which
    reproduces the result of the official IUCN generation length
    calculator. Columns: `age`, `lx`, `mx`.

  Supply `lx` and `mx` to use the life-table form; omit both for the
  event form.

- `"half_reproduction"` (50% of reproductive output):

  Age at which an individual reaches half of its lifetime reproductive
  output, averaged over individuals. Output is measured in offspring
  produced; supply that as `output`. A count of breeding events works as
  a proxy when every event yields the same number of offspring. Two
  input shapes are accepted:

  - event form: one row per breeding event with an `age` column (and
    `id` to separate individuals); each row counts as one unit of output
    when `output` is not supplied;

  - summarised form: one row per (`id`, `age`) with an `output` column
    giving the offspring produced at that age.

  The 50% age is the weighted median age: the smallest age at which the
  running total of output reaches half of the individual's lifetime
  total. Reproductive output happens *at* an age, so no value between
  age classes is invented. Columns: `age` (required), `id` (required
  with more than one individual), `output` (optional; omit for the
  one-event-per-row form).

- `"replacement"` (replacement rate):

  Time for the population to grow by its net reproductive rate R0 =
  sum(lx \* mx). With intrinsic growth rate `r` the population
  multiplies by exp(r \* t) each unit of time, so T = log(R0) / r, where
  `r` solves the Euler-Lotka equation sum(exp(-r \* x) \* lx \* mx) = 1.
  When the population is essentially stationary (R0 close to 1, r close
  to 0) the limit is the mean age of reproduction sum(x \* lx \* mx) /
  sum(lx \* mx), which is returned instead. Columns: `age`, `lx`, `mx`
  (all required).

## References

IUCN Standards and Petitions Committee. 2024. Guidelines for Using the
IUCN Red List Categories and Criteria. Version 16. Prepared by the
Standards and Petitions Committee. Pages 30-32.
<https://www.iucnredlist.org/documents/RedListGuidelines.pdf>

## Examples

``` r
# Mean age of parents at a stable age distribution
parents <- data.frame(age = c(5, 5, 3, 3, 4, 6, 6, 4, 5))
rl_generation_length(parents, "mean_parent", age = age)
#> [1] 4.555556

# Mean age of reproduction for one cohort
cohort <- data.frame(age_of_breeding = c(5, 5, 3, 8, 5, 6, 3, 8, 9, 4))
rl_generation_length(cohort, "mean_reproduction", age = age_of_breeding)
#> [1] 5.6

# Same definition from a life table, reproducing the official IUCN
# calculator (this input returns 10.5, as the IUCN workbook does)
# https://www.iucnredlist.org/resources/generation-length-calculator
life_table <- data.frame(
  age = 0:19,
  lx = c(1, 0.1, rep(0.01, 17), 0),
  mx = c(0, 0, 0, rep(30, 16), 0)
)
rl_generation_length(life_table, "mean_reproduction", age = age, lx = lx, mx = mx)
#> [1] 10.5

# 50% of reproductive output, several mothers, weighted by breeding counts
rep_data <- data.frame(
  mother = rep(c("m1", "m2"), each = 3),
  age = c(2, 3, 4, 2, 3, 4),
  n_offspring = c(2, 3, 2, 2, 2, 2)
)
rl_generation_length(rep_data, "half_reproduction",
                     age = age, id = mother, output = n_offspring)
#> [1] 3

# Replacement rate from a life table
life_table <- data.frame(
  age = 1:4,
  lx = c(1, 0.6, 0.3, 0.1),
  mx = c(0, 1.5, 2, 1)
)
rl_generation_length(life_table, "replacement", age = age, lx = lx, mx = mx)
#> [1] 2.465397
```
