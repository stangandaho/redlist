library(testthat)

# Tests for rl_green_status
test_that("rl_green_status returns expected output", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  result <- rl_green_status()
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})

# Tests for rl_habitats
test_that("rl_habitats basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all habitats
  all_habitats <- rl_habitats()
  expect_s3_class(all_habitats, "tbl_df")
  expect_true(nrow(all_habitats) > 0)

  # Test with numeric code
  desert_num <- rl_habitats(code = 8)
  expect_s3_class(desert_num, "tbl_df")

  # Test with character code
  desert_char <- rl_habitats(code = "8")
  expect_equal(desert_num, desert_char)
})

test_that("rl_habitats handles parameters correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with year parameter
  forest <- rl_habitats(code = 1, year_published = 2020)
  expect_s3_class(forest, "tbl_df")

  # Test with other parameters
  complex_query <- rl_habitats(
    code = c(1, 8),
    latest = TRUE,
    page = 2,
    pad_with_na = TRUE
  )
  expect_s3_class(complex_query, "tbl_df")
})

test_that("rl_habitats handles edge cases", {
  # Test invalid inputs
  expect_error(rl_habitats(code = TRUE))

  # Test non-existent code
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  expect_error(rl_habitats(code = 999))
})
