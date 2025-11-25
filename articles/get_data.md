# Get IUCN red list data with redlist R package

## What is IUCN red list ?

The [IUCN Red List of Threatened](https://www.iucnredlist.org/) Species
is a comprehensive global inventory that assesses the conservation
status of plant, animal, and fungi species. Managed by the International
Union for Conservation of Nature ([IUCN](https://iucn.org/)), it
evaluates species based on factors like population size, rate of
decline, and geographic range to classify them into categories such as
Least Concern, Vulnerable, Endangered, and Critically Endangered. The
Red List serves as a critical tool for conservation planning,
policy-making, and raising awareness about the risk of extinction facing
species worldwide. In this article, I demonstrate how to access Red List
data using the redlist R package.

## Install redlist R package

The package can be installed from github with *pak* package manager. The
*pak* package in R offers a faster, more reliable, and efficient way to
install packages compared to traditional methods. It handles
dependencies automatically, supports parallel downloads. Alternately is
{devtool} or *remotes*. I prefered to use *pak*.

``` r
# Install pak if not available
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

# Then install redlist
pak::pkg_install("stangandaho/redlist")
# Load the package
library(redlist)
```

## Set up an API key

If you’re using this package for the first time, you’ll likely need an
IUCN Red List API key. You can check whether it’s set by running
[`rl_check_api()`](https://stangandaho.github.io/redlist/reference/rl_check_api.md).
If this throws an error like ‘*! No Redlist API key found…* ’, you’ll
need to set an API key before using any of the package functions. Just
follow these two simple steps:  
1. Click [here](https://api.iucnredlist.org/users/edit) to create an
account if you don’t already have one. Once logged in, you can generate
your API key.  
2. Copy your API key and set it using the
[`rl_set_api()`](https://stangandaho.github.io/redlist/reference/rl_set_api.md)
function, like this `rl_set_api("2GoWiThmYrEDlitApiThatWorkS4me")`.  
You can then run
[`rl_check_api()`](https://stangandaho.github.io/redlist/reference/rl_check_api.md)
again to confirm that your API key is set successfully.

## Get data

The IUCN provides extensive data through the Red List across various
categories, including assessments, biogeographical realms, comprehensive
groups, conservation actions, habitats, population trends, red list
categories, taxonomic levels, and more. A complete overview, along with
the corresponding access functions, can be found
[here](https://stangandaho.github.io/redlist/reference/index.html#assessment).
In this article, we will focus specifically on data related to
threatened species that have been assessed in
[Benin](https://fr.wikipedia.org/wiki/B%C3%A9nin).

``` r
benin_redlist <- rl_countries(code = "BJ")
head(benin_redlist)
```

| country_description_en | country_code | assessments_year_published | assessments_latest | assessments_possibly_extinct | assessments_possibly_extinct_in_the_wild | assessments_sis_taxon_id | assessments_url                                     | assessments_taxon_scientific_name | assessments_red_list_category_code | assessments_assessment_id | assessments_code | assessments_code_type | assessments_scopes_description_en | assessments_scopes_code |
|:-----------------------|:-------------|---------------------------:|:-------------------|:-----------------------------|:-----------------------------------------|-------------------------:|:----------------------------------------------------|:----------------------------------|:-----------------------------------|--------------------------:|:-----------------|:----------------------|:----------------------------------|------------------------:|
| Benin                  | BJ           |                       2013 | FALSE              | FALSE                        | FALSE                                    |                   137286 | <https://www.iucnredlist.org/species/137286/522738> | Caccobius ferrugineus             | LC                                 |                    522738 | BJ               | country               | Global                            |                       1 |
| Benin                  | BJ           |                       2025 | TRUE               | FALSE                        | FALSE                                    |                   137829 | <https://www.iucnredlist.org/species/137829/531737> | Garreta laetus                    | LC                                 |                    531737 | BJ               | country               | Global                            |                       1 |
| Benin                  | BJ           |                       2014 | TRUE               | FALSE                        | FALSE                                    |                   137859 | <https://www.iucnredlist.org/species/137859/532227> | Pedaria estellae                  | LC                                 |                    532227 | BJ               | country               | Global                            |                       1 |
| Benin                  | BJ           |                       2013 | TRUE               | FALSE                        | FALSE                                    |                   137957 | <https://www.iucnredlist.org/species/137957/533937> | Trichonthophagus juvencus         | LC                                 |                    533937 | BJ               | country               | Global                            |                       1 |
| Benin                  | BJ           |                       2014 | TRUE               | FALSE                        | FALSE                                    |                   138000 | <https://www.iucnredlist.org/species/138000/534595> | Pedaria criberrima                | LC                                 |                    534595 | BJ               | country               | Global                            |                       1 |
| Benin                  | BJ           |                       2013 | TRUE               | FALSE                        | FALSE                                    |                   138301 | <https://www.iucnredlist.org/species/138301/539328> | Latodrepanus laticollis           | LC                                 |                    539328 | BJ               | country               | Global                            |                       1 |

By default, the function retrieves the first page of results, which
includes the first 100 records across various years. You can specify one
or more pages, as well as specific publication years, to filter the data
accordingly. If you want to retrieve all available data without
restricting by page, you can set the page argument to `NA` or `NULL`.

``` r
# Get data from five first pages
benin_redlist <- rl_countries(code = "BJ", page = 1:5)
# Get data from two first pages specifically for 2023
benin_redlist <- rl_countries(code = "BJ", page = 1:5, year_published = 2023)
# Get all data on Benin
benin_redlist <- rl_countries(code = "BJ", page = NA)
```

As displayed, each output from *redlist* functions is returned as a
tibble, allowing us to easily filter observations for analytical
purposes. In the article on [data
visulisation](https://stangandaho.github.io/redlist/articles/data_visualisation.html),
I’ll present a few examples of plots to illustrate how the data can be
explored visually.

To get detailed information about each species or observation, you can
use one of two functions by passing data from this output. For example,
you can use the function
[`rl_sis()`](https://stangandaho.github.io/redlist/reference/rl_sis.md)
and pass a species `sis_id` (e.g., `137286` for the first row).
Alternatively, you can use the
[`rl_assessment_id()`](https://stangandaho.github.io/redlist/reference/rl_assessment_id.md)
function, which accepts a species `assessment_id` (e.g., `522738`). The
[`rl_assessment_id()`](https://stangandaho.github.io/redlist/reference/rl_assessment_id.md)
function returns more detailed data than
[`rl_sis()`](https://stangandaho.github.io/redlist/reference/rl_sis.md).

If you need information for multiple species, you can simply loop
through the `assessments_assessment_id` column and combine the data row
by row.

``` r
all_species_details <- lapply(benin_redlist$assessments_assessment_id, function(x){
  rl_assessment_id(id)
}) %>% 
  dplyr::bind_rows()
```
