# Find the IUCN Red List threat category interactively

An interactive decision tree that walks you through the five IUCN Red
List criteria (A to E) like a form filled in at the console, and tells
you which threatened category (Critically Endangered, Endangered or
Vulnerable) your values meet. You can go back to any earlier question to
change an answer, and you review all your answers before the result is
shown.

## Usage

``` r
rl_threat_category()
```

## Value

Invisibly, an object of class `rl_threat_category`: a list with

- `category`:

  `"CR"`, `"EN"`, `"VU"`, or `NA` when no threatened category is met;

- `criteria`:

  the criteria met at that category, for example `"A2; B1ab"`, or `NA`;

- `details`:

  a tibble with one row per criterion assessed and the columns
  `criterion`, `category`, `code` and `reason`;

- `answers`:

  a list of the values you entered.

Printing the object shows the report again. If you quit, `NULL` is
returned invisibly.

## Details

Start by choosing the criteria you have data for; only the questions for
those criteria are asked. At every prompt you can type:

- `b`:

  go back to the previous question;

- `q`:

  quit without a result;

- `?`:

  show help for the current question;

- Enter:

  keep your current answer when you come back to a question, or leave an
  optional value unknown;

- `na`:

  set an optional value back to unknown.

The thresholds are those of the summary of the five criteria in the IUCN
Red List Categories and Criteria:

|  |  |  |  |
|----|----|----|----|
| Criterion | CR | EN | VU |
| A1 reduction | \>= 90% | \>= 70% | \>= 50% |
| A2, A3, A4 reduction | \>= 80% | \>= 50% | \>= 30% |
| B1 extent of occurrence | \< 100 km2 | \< 5,000 km2 | \< 20,000 km2 |
| B2 area of occupancy | \< 10 km2 | \< 500 km2 | \< 2,000 km2 |
| B(a) number of locations | 1 | \<= 5 | \<= 10 |
| C mature individuals | \< 250 | \< 2,500 | \< 10,000 |
| C2a(i) largest subpopulation | \<= 50 | \<= 250 | \<= 1,000 |
| C2a(ii) share in one subpopulation | 90-100% | 95-100% | 100% |
| D mature individuals | \< 50 | \< 250 | \< 1,000 (D1) |
| E probability of extinction | \>= 50% in 10 years or 3 generations | \>= 20% in 20 years or 5 generations | \>= 10% in 100 years |

Criterion B also needs at least two of the conditions (a) severe
fragmentation or a limited number of locations, (b) continuing decline
and (c) extreme fluctuations. Criterion C also needs a continuing
decline (C1) or a continuing decline with a small or concentrated
subpopulation structure or extreme fluctuations (C2). D2 (a very
restricted range facing a plausible, fast-acting threat) applies to
Vulnerable only. When both are given and the extent of occurrence is
smaller than the area of occupancy, the extent of occurrence is raised
to equal it, as the guidelines require.

A taxon is listed in the most threatened category that any criterion
qualifies it for. When no criterion is met, the taxon does not qualify
for a threatened category on the information given; it may be Near
Threatened, Least Concern or Data Deficient, which this function does
not decide.

This is a screening aid, not a formal assessment. Read the definitions
of the terms used (location, severe fragmentation, continuing decline,
extreme fluctuations) in the IUCN guidelines before listing a taxon.

## References

IUCN. 2012. IUCN Red List Categories and Criteria: Version 3.1. Second
edition. Gland, Switzerland and Cambridge, UK: IUCN.

IUCN Standards and Petitions Committee. 2024. Guidelines for Using the
IUCN Red List Categories and Criteria. Version 16.
<https://cmsdocs.s3.amazonaws.com/RedListGuidelines.pdf>

## See also

[`rl_reduction()`](https://stangandaho.github.io/redlist/reference/rl_reduction.md)
to estimate a population reduction for criterion A,
[`rl_eoo()`](https://stangandaho.github.io/redlist/reference/rl_eoo.md)
and
[`rl_aoo()`](https://stangandaho.github.io/redlist/reference/rl_aoo.md)
for the criterion B range metrics, and
[`rl_generation_length()`](https://stangandaho.github.io/redlist/reference/rl_generation_length.md).

## Examples

``` r
if (FALSE) { # \dontrun{
res <- rl_threat_category()
res$category
res$details
} # }
```
