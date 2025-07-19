library(testthat)

test_that("rl_possibly_extinct returns expected output", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test basic functionality
  result <- rl_possibly_extinct()

  # Check output structure
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)

  # Test with pad_with_na = TRUE
  result_na <- rl_possibly_extinct(pad_with_na = TRUE)
})

test_that("rl_possibly_extinct handles API errors", {
  testthat::skip_on_cran()

  # Test with invalid URL (should error)
  expect_error({
    httr2::with_mock(
      ~ httr2::resp_status(404),
      rl_possibly_extinct()
    )
  })
})
