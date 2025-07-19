library(testthat)

test_that("rl_orders basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all orders (NULL case)
  all_orders <- rl_orders()
  expect_s3_class(all_orders, "tbl_df")
  expect_true(nrow(all_orders) > 0)

  # Test with valid order name
  carnivora <- rl_orders(order_name = "Carnivora")
  expect_s3_class(carnivora, "tbl_df")
  expect_true(nrow(carnivora) > 0)
})

test_that("rl_orders handles parameters correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with numeric year
  primates_2022 <- rl_orders(order_name = "Primates", year_published = 2022)
  expect_s3_class(primates_2022, "tbl_df")

  # Test with character year
  primates_char <- rl_orders(order_name = "Primates", year_published = "2022")
  expect_s3_class(primates_char, "tbl_df")

  # Test with other parameters
  complex_query <- rl_orders(
    order_name = "Rodentia",
    latest = TRUE,
    page = 2,
    pad_with_na = TRUE
  )
  expect_s3_class(complex_query, "tbl_df")
})

test_that("rl_orders handles edge cases", {
  # Test invalid order name
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  empty_result <- rl_orders(order_name = "NonexistentOrder")
  expect_s3_class(empty_result, "tbl_df")

  # Test invalid year doesn't throw error
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  invalid_year <- rl_orders(order_name = "Carnivora", year_published = "invalid")
  expect_s3_class(invalid_year, "tbl_df")
})
