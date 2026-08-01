# Offline behaviour of the exported API-key helpers. The network branch of
# rl_check_api() is covered separately (and excluded from coverage via
# .covrignore); here we exercise only the paths that need no connection.

test_that("rl_check_api aborts when no API key is set", {
  old <- Sys.getenv("REDLIST_API", unset = NA)
  Sys.setenv(REDLIST_API = "")
  on.exit(
    if (is.na(old)) Sys.unsetenv("REDLIST_API") else Sys.setenv(REDLIST_API = old),
    add = TRUE
  )
  expect_error(rl_check_api(), regexp = "No Redlist API key")
})

test_that("rl_set_api guides the user when called with no key", {
  expect_message(res <- rl_set_api(), regexp = "Missing API key")
  expect_null(res)
})

test_that("rl_set_api prints the setup steps when given a key", {
  expect_message(res <- rl_set_api("dummy-key"), regexp = "Renviron")
  expect_null(res)
})
