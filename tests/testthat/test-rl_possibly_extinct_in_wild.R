library(testthat)
library(httptest2)

test_that("rl_possibly_extinct_in_wild returns expected output", {
  with_mock_dir("rl_possibly_extinct_in_wild-basic", {
    # Test basic functionality
    result <- rl_possibly_extinct_in_wild()

    # Check output structure
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
  })
})

