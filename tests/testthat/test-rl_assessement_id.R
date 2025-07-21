library(testthat)
library(httptest2)

test_that("rl_assessement_id basic functionality works", {
  with_mock_dir("rl_assessement_id-basic", {
    default_assessment <- rl_assessement_id()
    expect_s3_class(default_assessment, "tbl_df")
    expect_true(nrow(default_assessment) > 0)
  })
})

test_that("rl_assessement_id handles parameters correctly", {
  with_mock_dir("rl_assessement_id-params", {
    padded_result <- rl_assessement_id(pad_with_na = TRUE)
    expect_s3_class(padded_result, "tbl_df")
  })
})

test_that("rl_assessement_id handles edge cases", {
  with_mock_dir("rl_assessement_id-edge", {
    expect_error(rl_assessement_id(assessment_id = 999999999))
  })
})
