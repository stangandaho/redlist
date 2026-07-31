# Offline behaviour of the exported API-key helpers. The network branch of
# rl_check_api() is covered separately (and excluded from coverage via
# .covrignore); here we exercise only the paths that need no connection.

test_that("rl_check_api aborts when no API key is set", {
  withr::local_envvar(REDLIST_API = "")
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
