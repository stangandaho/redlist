library(testthat)

test_that("rl_orders basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all orders
  all_orders <- rl_orders()
  expect_s3_class(all_orders, "tbl_df")
  expect_true(nrow(all_orders) > 0)
  expect_true("order_names" %in% names(all_orders))

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
  expect_equal(primates_2022, primates_char)

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

  # Test non-existent order
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  ## Return tbl even if the order doesn't exist
  fake_order <- rl_orders(order_name = "NonexistentOrder")
  expect_s3_class(fake_order, "tbl_df")
  expect_equal(nrow(fake_order), 1)

  # Test empty response handling
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  empty_resp <- rl_orders(order_name = "Carnivora", year_published = 2100)
  expect_s3_class(empty_resp, "tbl_df")
})
