library(testthat)
library(httptest2)

test_that("rl_possibly_extinct returns expected output", {
  with_mock_dir("rl_possibly_extinct-basic", {
    # Test basic functionality
    result <- rl_possibly_extinct()

    # Check output structure
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)

    # Test with pad_with_na = TRUE
    result_na <- rl_possibly_extinct(pad_with_na = TRUE)
    expect_s3_class(result_na, "tbl_df")
    expect_true(nrow(result_na) > 0)
  })
})
