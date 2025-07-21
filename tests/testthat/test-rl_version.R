library(testthat)
library(httptest2)

test_that("API version", {
  with_mock_dir("rl_version-basic", {
    result <- rl_version()
    expect_type(result, "character")
    expect_true(length(result) > 0)
  })
})
