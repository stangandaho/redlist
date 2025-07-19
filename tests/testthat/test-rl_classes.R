library(testthat)

test_that("rl_classes basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all classes (NULL case)
  all_classes <- rl_classes()
  expect_s3_class(all_classes, "tbl_df")
  expect_true(nrow(all_classes) > 0)

  # Test with valid class name
  mammals <- rl_classes(class_name = "Mammalia")
  expect_s3_class(mammals, "tbl_df")
  expect_true(nrow(mammals) > 0)
})

test_that("rl_classes handles parameters correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with numeric year range
  birds_recent <- rl_classes(class_name = "Aves", year_published = 2024:2025)
  expect_s3_class(birds_recent, "tbl_df")

  # Test with character year (should work same as numeric)
  birds_char <- rl_classes(class_name = "Aves", year_published = "2024")
  expect_s3_class(birds_char, "tbl_df")

  # Test with other parameters
  complex_query <- rl_classes(
    class_name = "Reptilia",
    latest = TRUE,
    page = 2,
    pad_with_na = TRUE
  )
  expect_s3_class(complex_query, "tbl_df")
})

test_that("rl_classes handles edge cases", {
  # Test invalid class name
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  empty_result <- rl_classes(class_name = "NonexistentClass")
  expect_s3_class(empty_result, "tbl_df")

  # Test invalid year doesn't throw error
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  invalid_year <- rl_classes(class_name = "Mammalia", year_published = "invalid")
  expect_s3_class(invalid_year, "tbl_df")
})
