# Set the IUCN Red List API key

The function provide steps to set the IUCN Red List API key.

## Usage

``` r
rl_set_api(api_key)
```

## Arguments

- api_key:

  Character. The API key provided by the IUCN Red List to authenticate
  requests, obtainable at [IUCN Red List API
  website](https://api.iucnredlist.org/users/sign_in).

## Value

Invisibly returns `NULL` after setting the API key.

## Examples

``` r
if (FALSE) { # \dontrun{
# Set the API key for the IUCN Red List
rl_set_api("your_api_key")
} # }
```
