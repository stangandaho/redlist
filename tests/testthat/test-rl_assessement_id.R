library(testthat)

test_that("rl_assessement_id basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with default assessment ID
  default_assessment <- rl_assessement_id()
  expect_s3_class(default_assessment, "tbl_df")
  expect_true(nrow(default_assessment) > 0)
})

test_that("rl_assessement_id handles parameters correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with pad_with_na = TRUE
  padded_result <- rl_assessement_id(pad_with_na = TRUE)
  expect_s3_class(padded_result, "tbl_df")
})

test_that("rl_assessement_id handles edge cases", {
  # Test with invalid assessment ID
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  expect_error(rl_assessement_id(assessment_id = 999999999))

})
