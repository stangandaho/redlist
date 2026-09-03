# Population reduction for IUCN criterion A

Estimate the population reduction of a taxon over the most recent three
generations (or ten years, whichever is longer), following section 4.5
of the IUCN Red List guidelines. A decline model is fitted to the
population estimates and used to read off the population size at the
start and end of the window, and the reduction is the proportional drop
between them. The same calculation gives the estimated continuing
decline of criterion C1 and B when a different window is set through
`years`.

## Usage

``` r
rl_reduction(
  population,
  time,
  generation_length,
  model = c("exponential", "linear"),
  assessment_year = NULL,
  years = NULL,
  subcriterion = c("A2", "A1", "A3", "A4")
)
```

## Arguments

- population:

  Numeric vector of population sizes (number of mature individuals, or
  an index that scales with it).

- time:

  Numeric vector of the years the sizes refer to, the same length as
  `population`.

- generation_length:

  Generation length in years. See
  [`rl_generation_length()`](https://stangandaho.github.io/redlist/reference/rl_generation_length.md).

- model:

  Decline pattern, `"exponential"` (default) or `"linear"`.

- assessment_year:

  The year taken as the present. Default is the most recent year in
  `time`.

- years:

  Length of the assessment window in years. Default is the longer of
  three generations or ten years.

- subcriterion:

  Which criterion A subcriterion sets the thresholds for `category_a`:
  `"A2"` (default), `"A1"`, `"A3"` or `"A4"`.

## Value

A one row tibble with the model and window used, the fitted population
sizes at the start and end of the window (`n_start`, `n_present`), the
`reduction` (a proportion) and `reduction_pct`, and `category_a`.

## Details

Two decline patterns are supported.

- `"exponential"`:

  a constant proportional rate of decline, fitted as a log-linear
  regression of population size on time. Appropriate when the rate of
  loss stays proportional to population size, for example a constant
  harvest fraction.

- `"linear"`:

  a constant number of individuals lost per year, fitted as a linear
  regression of population size on time. Appropriate when a fixed amount
  is removed each year, for example a fixed area of habitat lost.

With exactly two estimates the fit passes through both points,
reproducing the two-point formulas in the guidelines. With more
estimates the regression smooths natural variation, and the reduction is
still read over the most recent window.

The `category_a` column reports the most threatened band the reduction
reaches for the chosen subcriterion, or `NA` when it reaches none
(including an increase). The criterion A thresholds are 50/70/90 percent
(VU/EN/CR) for `"A1"` and 30/50/80 percent for `"A2"`, `"A3"` and
`"A4"`. This is the magnitude threshold only, not a full assessment.

## References

IUCN Standards and Petitions Committee. 2024. Guidelines for Using the
IUCN Red List Categories and Criteria. Version 16, section 4.5.
<https://www.iucnredlist.org/documents/RedListGuidelines.pdf>

## See also

[`rl_overall_reduction()`](https://stangandaho.github.io/redlist/reference/rl_overall_reduction.md),
[`rl_generation_length()`](https://stangandaho.github.io/redlist/reference/rl_generation_length.md)

## Examples

``` r
# Guidelines example: 20000 in 1961 and 14000 in 1981, generation length 20,
# assessed in 2001 so the three generation window runs 1941 to 2001.
# Exponential decline gives a 65.7 percent reduction.
rl_reduction(population = c(20000, 14000), time = c(1961, 1981),
             generation_length = 20, model = "exponential",
             assessment_year = 2001)
#> # A tibble: 1 × 11
#>   model      subcriterion generation_length window_years year_start year_present
#>   <chr>      <chr>                    <dbl>        <dbl>      <dbl>        <dbl>
#> 1 exponenti… A2                          20           60       1941         2001
#> # ℹ 5 more variables: n_start <dbl>, n_present <dbl>, reduction <dbl>,
#> #   reduction_pct <dbl>, category_a <chr>

# The same data under a linear decline gives 69.2 percent.
rl_reduction(population = c(20000, 14000), time = c(1961, 1981),
             generation_length = 20, model = "linear",
             assessment_year = 2001)
#> # A tibble: 1 × 11
#>   model  subcriterion generation_length window_years year_start year_present
#>   <chr>  <chr>                    <dbl>        <dbl>      <dbl>        <dbl>
#> 1 linear A2                          20           60       1941         2001
#> # ℹ 5 more variables: n_start <dbl>, n_present <dbl>, reduction <dbl>,
#> #   reduction_pct <dbl>, category_a <chr>
```
