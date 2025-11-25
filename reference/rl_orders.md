# IUCN Red List taxa by order

Retrieve species assessments by taxonomic order. If `order_name = NULL`,
it returns a list of available orders. If `order_name` is provided, it
retrieves assessments for species in the specified order.

## Usage

``` r
rl_orders(
  order_name = NULL,
  year_published = NULL,
  latest = NULL,
  scope_code = NULL,
  page = 1
)
```

## Arguments

- order_name:

  Character. The order name (e.g., "Carnivora"). Use `rl_orders()` to
  list available orders.

- year_published:

  Optional. Single or numeric vector of years to filter assessments by
  publication year.

- latest:

  Optional. Logical. If `TRUE`, return only the latest assessment per
  species.

- scope_code:

  Optional. Integer One or more scope codes to filter assessments.

- page:

  Optional. Integer vector. Specify one or more page numbers to fetch.
  If `NULL` or `NA`, all pages will be fetched automatically.

## Value

A tibble (class `tbl_df`, `tbl`, `data.frame`) where each column
represents a unique API response JSON key. If `order_name = NULL`, the
tibble contains available taxonomic orders with a column for order
names. If `order_name` is provided, the tibble contains assessment data
for the specified order, including year, taxon details, criteria, and
other relevant metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all available orders
rl_orders()

# Get assessments for Carnivora order
rl_orders(order_name = "Carnivora")

# Get latest Primates assessments published in 2022
rl_orders(
  order_name = "Primates",
  year_published = 2022,
  latest = TRUE
)
} # }
```
