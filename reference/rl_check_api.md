# Check IUCN Red List API Status

Verifies whether the IUCN Red List API is accessible and the provided
API key is valid.

## Usage

``` r
rl_check_api()
```

## Value

Invisibly returns `TRUE` if the API is working properly. If not, the
function will abort with an appropriate error message.

## See also

[`rl_set_api()`](https://stangandaho.github.io/redlist/reference/rl_set_api.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Check if API is properly set up
rl_check_api()
} # }
```
