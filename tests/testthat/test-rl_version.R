library(testthat)

test_that("API version", {
  expect_true(inherits(class(rl_version()), "character"))
})
