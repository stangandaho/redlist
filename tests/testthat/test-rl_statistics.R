library(testthat)

test_that("rl_statistics returns expected output", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test basic functionality
  result <- rl_statistics()

  # Check output structure
  expect_s3_class(result, "tbl_df")
  expect_named(result, c("count", "date_of_access"))
  expect_type(result$count, "integer")
  expect_s3_class(result$date_of_access, "POSIXt")

  # Verify count is reasonable (> 0)
  expect_true(result$count > 0)
})
