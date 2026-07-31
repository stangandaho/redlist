
#' Open file for editing
#'
#' Opens a specified file for editing in the system's default editor (as configured by R).
#'
#' @param path Optional character string specifying the path to the file to open.
#'   If `NULL` (default), a `.Renviron` file is opened based on the value of `scope`.
#' @param scope Character string indicating which `.Renviron` file to open when `path = NULL`:
#' - `user`: Opens the user-level `.Renviron`
#' - `project`: Opens or creates a `.Renviron` file in the current working directory
#'
#' @return (Invisibly) returns the path to the file opened.
#'
#' @examples
#' \dontrun{
#' # Open user-level .Renviron
#' open_file()
#' }
#'
#' @export
rl_open_file <- function(path = NULL, scope = c("user", "project")) {
  scope <- base::match.arg(scope)
  renviron <- is.null(path)

  # Determine file path
  if (is.null(path)) {
    path <- if (scope == "user") {
      base::path.expand("~/.Renviron")
    } else {
      base::file.path(getwd(), ".Renviron")
    }
  } else {
    path <- base::path.expand(path)
  }
  # Ensure absolute path (canonical)
  path <- base::normalizePath(path, winslash = "/", mustWork = FALSE)

  # If file doesn't exist, ensure directory and create file
  if (!file.exists(path)) {
    #cli::cli_abort("Path {.file {path}} doesn't exist.")
    file.create(path, showWarnings = FALSE)
  }

  if (renviron) {
    bullet <- cli::col_red(cli::symbol$bullet)
    cli::cli_inform("{bullet} Modify {.file {path}}")
    cli::cli_inform("{bullet} Restart R for changes to take effect")
    cli::cli_end()
  }

  # Open in system default editor
  utils::file.edit(path)

  invisible(path)
}

