library(testthat)

test_that("rl_growth_forms basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all growth forms
  all_forms <- rl_growth_forms()
  expect_s3_class(all_forms, "tbl_df")
  expect_true(nrow(all_forms) > 0)
})

test_that("rl_growth_forms handles parameters correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with numeric year
  recent_forms <- rl_growth_forms(code = "GE", year_published = 2020)
  expect_s3_class(recent_forms, "tbl_df")

  # Test with character year
  recent_forms_char <- rl_growth_forms(code = "GE", year_published = "2020")
  expect_equal(recent_forms, recent_forms_char)

  # Test with other parameters
  complex_query <- rl_growth_forms(
    code = "L",
    latest = TRUE,
    page = 2,
    pad_with_na = TRUE
  )
  expect_s3_class(complex_query, "tbl_df")
})

test_that("rl_growth_forms handles edge cases", {
  # Test invalid inputs
  expect_error(rl_growth_forms(code = 123))

  # Test non-existent code
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  expect_error(rl_growth_forms(code = "INVALID"))
})
