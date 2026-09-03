# Overall reduction across subpopulations for IUCN criterion A

Combine the reductions of several subpopulations into one reduction for
the taxon, following section 4.5.4 of the IUCN Red List guidelines. The
overall reduction is the change in the summed population, which equals
the average of the subpopulation reductions weighted by their size three
generations ago.

## Usage

``` r
rl_overall_reduction(
  past = NULL,
  present = NULL,
  reduction = NULL,
  subpopulation = NULL,
  subcriterion = c("A2", "A1", "A3", "A4")
)
```

## Arguments

- past:

  Numeric vector of subpopulation sizes at the start of the window
  (three generations ago).

- present:

  Numeric vector of subpopulation sizes at the end of the window.

- reduction:

  Numeric vector of subpopulation reductions (proportions).

- subpopulation:

  Optional labels for the subpopulations.

- subcriterion:

  Which criterion A subcriterion sets the thresholds for `category_a`:
  `"A2"` (default), `"A1"`, `"A3"` or `"A4"`.

## Value

A one row tibble with the overall `reduction` and `reduction_pct`, the
number of subpopulations, the summed past and present sizes, and
`category_a`. The per-subpopulation table is attached as the
`"subpopulations"` attribute.

## Details

Give any two of `past`, `present` and `reduction` for each subpopulation
and the third is worked out from `reduction = 1 - present / past`. The
sizes should already be projected to the start and end of the same
window, for example with
[`rl_reduction()`](https://stangandaho.github.io/redlist/reference/rl_reduction.md).

## References

IUCN Standards and Petitions Committee. 2024. Guidelines for Using the
IUCN Red List Categories and Criteria. Version 16, section 4.5.4.

## See also

[`rl_reduction()`](https://stangandaho.github.io/redlist/reference/rl_reduction.md)

## Examples

``` r
# Guidelines Example 1: past and present sizes for three subpopulations
rl_overall_reduction(
  past = c(10000, 8000, 12000),
  present = c(5000, 9000, 2000),
  subpopulation = c("Pacific", "Atlantic", "Indian")
)
#> # A tibble: 1 × 6
#>   reduction reduction_pct n_subpop past_total present_total category_a
#>       <dbl>         <dbl>    <int>      <dbl>         <dbl> <chr>     
#> 1     0.467          46.7        3      30000         16000 VU        
```
