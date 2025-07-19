library(testthat)

test_that("rl_research basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all research categories
  all_categories <- rl_research()
  expect_s3_class(all_categories, "tbl_df")
  expect_true(nrow(all_categories) > 0)

  # Test with numeric code
  res_num <- rl_research(code = 1)
  expect_s3_class(res_num, "tbl_df")

  # Test with character code
  res_char <- rl_research(code = "1")
  expect_equal(res_num, res_char)

  # Test with compound code
  res_compound <- rl_research(code = "3_1")
  expect_s3_class(res_compound, "tbl_df")
})

test_that("rl_research handles parameters correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with numeric year
  res_year_num <- rl_research(code = 1, year_published = 2020)
  expect_s3_class(res_year_num, "tbl_df")

  # Test with character year
  res_year_char <- rl_research(code = 1, year_published = "2020")
  expect_equal(res_year_num, res_year_char)

  # Test with other parameters
  res_complex <- rl_research(
    code = 1,
    latest = TRUE,
    page = 2,
    pad_with_na = TRUE
  )
  expect_s3_class(res_complex, "tbl_df")
})

test_that("rl_research handles edge cases", {
  # Test invalid inputs
  expect_error(rl_research(code = TRUE))

})
