# Population reduction (IUCN Criterion A)

``` r

library(redlist)
```

## What criterion A measures

Criterion A looks at how much a population has shrunk. In the guidelines
a reduction is a decline in the number of mature individuals of at least
a stated percentage over a set period, three generations or ten years,
whichever is longer. The decline need not still be going on. This is
different from the continuing decline used in criteria B and C, which is
about a trend that is likely to carry on.

[`rl_reduction()`](https://stangandaho.github.io/redlist/reference/rl_reduction.md)
computes that percentage from a series of population estimates, and
[`rl_overall_reduction()`](https://stangandaho.github.io/redlist/reference/rl_overall_reduction.md)
combines several subpopulations into one figure for the taxon. Neither
needs an internet connection, so the examples below run as you read
them.

## From two estimates

The simplest case has two counts. Suppose a species with a 20 year
generation length was estimated at 20000 individuals in 1961 and 14000
in 1981, and we are assessing it in 2001. The three generation window
then runs from 1941 to 2001, so we extrapolate back to 1941 and forward
to 2001.

``` r

rl_reduction(
  population = c(20000, 14000),
  time = c(1961, 1981),
  generation_length = 20,
  model = "exponential",
  assessment_year = 2001
)
#> # A tibble: 1 × 11
#>   model      subcriterion generation_length window_years year_start year_present
#>   <chr>      <chr>                    <dbl>        <dbl>      <dbl>        <dbl>
#> 1 exponenti… A2                          20           60       1941         2001
#> # ℹ 5 more variables: n_start <dbl>, n_present <dbl>, reduction <dbl>,
#> #   reduction_pct <dbl>, category_a <chr>
```

The arguments:

- `population` and `time` are the counts and the years they refer to, as
  two vectors of the same length.
- `generation_length` is the generation length in years. If you do not
  have it,
  [`rl_generation_length()`](https://stangandaho.github.io/redlist/reference/rl_generation_length.md)
  can estimate it from life history data.
- `model` is the shape of the decline. `"exponential"` assumes a
  constant proportional rate, which suits a threat that takes a fixed
  fraction each year, such as a steady harvest rate. `"linear"` assumes
  a constant number of individuals lost each year, which suits a fixed
  amount of habitat cleared annually.
- `assessment_year` is the year treated as the present. Here the data
  end in 1981 but the assessment is made in 2001, so we say so. Left
  out, it defaults to the most recent year in `time`.
- `years` sets the window length. Left out, it is the longer of three
  generations or ten years.

The result gives the fitted sizes at the start and end of the window
(`n_start`, `n_present`), the reduction as a proportion and a
percentage, and a threshold flag. The choice of model matters. The same
data read as a linear decline give a larger figure, because a fixed
yearly loss is a growing share of a shrinking population.

``` r

rl_reduction(
  population = c(20000, 14000),
  time = c(1961, 1981),
  generation_length = 20,
  model = "linear",
  assessment_year = 2001
)
#> # A tibble: 1 × 11
#>   model  subcriterion generation_length window_years year_start year_present
#>   <chr>  <chr>                    <dbl>        <dbl>      <dbl>        <dbl>
#> 1 linear A2                          20           60       1941         2001
#> # ℹ 5 more variables: n_start <dbl>, n_present <dbl>, reduction <dbl>,
#> #   reduction_pct <dbl>, category_a <chr>
```

When you cannot choose between the patterns, running both gives a
plausible range for the reduction, which is the honest way to report it.

## From several estimates

With more than two counts, the same call fits a regression through all
of them, which smooths out year to year variation. Exponential uses a
log-linear fit, linear uses a straight line. The reduction is still read
over the most recent window.

``` r

years <- 2000:2020
counts <- round(10000 * 0.97^(0:20))
rl_reduction(counts, years, generation_length = 7)
#> # A tibble: 1 × 11
#>   model      subcriterion generation_length window_years year_start year_present
#>   <chr>      <chr>                    <dbl>        <dbl>      <dbl>        <int>
#> 1 exponenti… A2                           7           21       1999         2020
#> # ℹ 5 more variables: n_start <dbl>, n_present <dbl>, reduction <dbl>,
#> #   reduction_pct <dbl>, category_a <chr>
```

## Reading the category

The `category_a` column reports the most threatened band the reduction
reaches: `"CR"`, `"EN"`, `"VU"`, or `NA` when it reaches none, including
the case of an increase. The thresholds depend on the subcriterion.

| subcriterion | VU  | EN  | CR  |
|--------------|-----|-----|-----|
| A1           | 50% | 70% | 90% |
| A2, A3, A4   | 30% | 50% | 80% |

A1 applies when the causes are reversible, understood, and have ceased,
so it uses higher thresholds. The default is A2. Set `subcriterion` to
change it.

``` r

r <- rl_reduction(c(20000, 14000), c(1961, 1981),
                  generation_length = 20, assessment_year = 2001)
c(A2 = r$category_a,
  A1 = rl_reduction(c(20000, 14000), c(1961, 1981),
                    generation_length = 20, assessment_year = 2001,
                    subcriterion = "A1")$category_a)
#>   A2   A1 
#> "EN" "VU"
```

Keep in mind that this flag is the magnitude threshold only. A full
criterion A listing also depends on the subcriterion conditions, such as
whether the causes are understood and reversible, so treat the column as
a guide rather than a verdict.

## Continuing decline for criterion C1

Criterion C1 needs an estimated continuing decline rather than a
reduction, but the calculation is the same. The difference is the
window: one, two, or three generations depending on the category. Set
`years` to that window.

``` r

# a one generation decline for the Vulnerable threshold under C1
rl_reduction(counts, years, generation_length = 7, years = 7)
#> # A tibble: 1 × 11
#>   model      subcriterion generation_length window_years year_start year_present
#>   <chr>      <chr>                    <dbl>        <dbl>      <dbl>        <int>
#> 1 exponenti… A2                           7            7       2013         2020
#> # ℹ 5 more variables: n_start <dbl>, n_present <dbl>, reduction <dbl>,
#> #   reduction_pct <dbl>, category_a <chr>
```

## Combining subpopulations

For a widely distributed taxon the reduction should be worked out for
each subpopulation and then combined, weighted by the size of each
subpopulation at the start of the window.
[`rl_overall_reduction()`](https://stangandaho.github.io/redlist/reference/rl_overall_reduction.md)
does the weighting. Give it any two of `past`, `present`, and
`reduction` for each subpopulation and it fills in the third.

``` r

overall <- rl_overall_reduction(
  past = c(10000, 8000, 12000),
  present = c(5000, 9000, 2000),
  subpopulation = c("Pacific", "Atlantic", "Indian")
)
overall
#> # A tibble: 1 × 6
#>   reduction reduction_pct n_subpop past_total present_total category_a
#>       <dbl>         <dbl>    <int>      <dbl>         <dbl> <chr>     
#> 1     0.467          46.7        3      30000         16000 VU
```

The overall reduction is the change in the summed population. Note that
a simple average of the three subpopulation reductions would be wrong
here, because the Indian Ocean subpopulation was the largest and fell
the most, so it carries more weight. The per subpopulation breakdown is
kept alongside the result.

``` r

attr(overall, "subpopulations")
#> # A tibble: 3 × 5
#>   subpopulation  past present reduction weight
#>   <chr>         <dbl>   <dbl>     <dbl>  <dbl>
#> 1 Pacific       10000    5000     0.5    0.333
#> 2 Atlantic       8000    9000    -0.125  0.267
#> 3 Indian        12000    2000     0.833  0.4
```

When a subpopulation has only a known reduction and a recent count, pass
those two and the past size is recovered from them, which matches the
way the guidelines complete such a table.

``` r

rl_overall_reduction(
  present = c(4403, 9074, 1312),
  reduction = c(0.50, -0.179, 0.70)
)
#> # A tibble: 1 × 6
#>   reduction reduction_pct n_subpop past_total present_total category_a
#>       <dbl>         <dbl>    <int>      <dbl>         <dbl> <chr>     
#> 1     0.292          29.2        3     20876.         14789 NA
```
