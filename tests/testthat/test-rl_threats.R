library(testthat)

test_that("rl_threats basic functionality", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all threats
  all_threats <- rl_threats()
  expect_s3_class(all_threats, "tbl_df")
  expect_true(nrow(all_threats) > 0)

  # Test with numeric code
  res_num <- rl_threats(code = 1)
  expect_s3_class(res_num, "tbl_df")
  expect_true(nrow(res_num) > 0)

  # Test with character code
  res_char <- rl_threats(code = "1")
  expect_s3_class(res_char, "tbl_df")
  expect_equal(res_num, res_char) # Should be identical

  # Test with multiple codes
  res_multi <- rl_threats(code = c("1", "2"))
  expect_s3_class(res_multi, "tbl_df")
  expect_true(nrow(res_multi) >= nrow(res_num))
})

test_that("rl_threats with parameters", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with year_published (numeric)
  res_year_num <- rl_threats(code = 1, year_published = 2020)
  expect_s3_class(res_year_num, "tbl_df")

  # Test with year_published (character)
  res_year_char <- rl_threats(code = 1, year_published = "2020")
  expect_equal(res_year_num, res_year_char)

  # Test with other parameters
  res_complex <- rl_threats(
    code = 1,
    latest = TRUE,
    page = 2
  )
  expect_s3_class(res_complex, "tbl_df")
})
