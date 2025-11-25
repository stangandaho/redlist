# Open file for editing

Opens a specified file for editing in the system's default editor (as
configured by R).

## Usage

``` r
rl_open_file(path = NULL, scope = c("user", "project"))
```

## Arguments

- path:

  Optional character string specifying the path to the file to open. If
  `NULL` (default), a `.Renviron` file is opened based on the value of
  `scope`.

- scope:

  Character string indicating which `.Renviron` file to open when
  `path = NULL`:

  - `user`: Opens the user-level `.Renviron`

  - `project`: Opens or creates a `.Renviron` file in the current
    working directory

## Value

(Invisibly) returns the path to the file opened.

## Examples

``` r
if (FALSE) { # \dontrun{
# Open user-level .Renviron
open_file()
} # }
```
