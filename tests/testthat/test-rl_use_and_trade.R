library(testthat)

test_that("rl_use_and_trade returns expected results", {
  # Mock the API response or use testthat's built-in mocking if available
  # For this example, we'll assume we're testing with the real API

  # Test that function returns a tibble when code is NULL
  testthat::skip_on_cran() # Skip on CRAN to avoid API calls
  testthat::skip_if_offline() # Skip if offline

  result1 <- rl_use_and_trade()
  expect_s3_class(result1, "tbl_df")
  expect_true(nrow(result1) > 0)

  # Test with a specific code
  result2 <- rl_use_and_trade(code = "1")
  expect_s3_class(result2, "tbl_df")
  expect_true(nrow(result2) > 0)

  # Test with multiple codes
  result3 <- rl_use_and_trade(code = c("1", "2"))
  expect_s3_class(result3, "tbl_df")
  expect_true(nrow(result3) > 0)

  # Test with additional parameters
  result4 <- rl_use_and_trade(code = "1", year_published = 2020)
  expect_s3_class(result4, "tbl_df")

  # Test with pagination
  result5 <- rl_use_and_trade(code = "1", page = 2)
  expect_s3_class(result5, "tbl_df")

  # Test error handling for invalid codes
  expect_error(rl_use_and_trade(code = "invalid_code"))
})

test_that("rl_use_and_trade handles edge cases", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with empty result
  result <- rl_use_and_trade(code = "1", year_published = 2100)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)

})

test_that("rl_use_and_trade parameter validation works", {
  # Test invalid parameter types
  expect_error(rl_use_and_trade(code = .)) # code should be character

})
