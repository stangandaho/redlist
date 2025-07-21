library(testthat)
library(httptest2)

test_that("rl_statistics returns expected output", {
  with_mock_dir("rl_statistics-basic", {
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
})
