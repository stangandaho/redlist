library(testthat)

test_that("rl_sis returns expected results", {
  # Skip tests that require API calls on CRAN or when offline
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with default SIS ID (179359)
  result1 <- rl_sis()
  expect_s3_class(result1, "tbl_df")
  expect_true(nrow(result1) > 0)
  expect_true("sis_id" %in% names(result1))
  expect_true(all(result1$sis_id == 179359))

  # Test with specific SIS ID
  result2 <- rl_sis(sis_id = 22694927) # African elephant
  expect_s3_class(result2, "tbl_df")
  expect_true(nrow(result2) > 0)
  expect_true(all(result2$sis_id[1] == 22694927))

})
