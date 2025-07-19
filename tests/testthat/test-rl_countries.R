library(testthat)

test_that("rl_countries basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all countries
  all_countries <- rl_countries()
  expect_s3_class(all_countries, "tbl_df")
  expect_true(nrow(all_countries) > 0)

  # Test with single country code
  brazil <- rl_countries(code = "BR")
  expect_s3_class(brazil, "tbl_df")
  expect_true(nrow(brazil) > 0)

  # Test with multiple country codes
  multi_countries <- rl_countries(code = c("BJ", "CA"))
  expect_s3_class(multi_countries, "tbl_df")
})

test_that("rl_countries handles parameters correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with numeric year
  canada_2020 <- rl_countries(code = "CA", year_published = 2020)
  expect_s3_class(canada_2020, "tbl_df")

  # Test with character year
  canada_char <- rl_countries(code = "CA", year_published = "2020")
  expect_equal(canada_2020, canada_char)

  # Test with pagination
  paged_results <- rl_countries(code = "BR", page = 2)
  expect_s3_class(paged_results, "tbl_df")
})

test_that("rl_countries handles edge cases", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  # Test invalid inputs
  expect_error(rl_countries(code = 123))
  expect_error(rl_countries(code = "XX"))

})
