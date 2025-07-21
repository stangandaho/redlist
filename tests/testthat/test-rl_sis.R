library(testthat)
library(httptest2)

test_that("rl_sis returns expected results", {
  with_mock_dir("rl_sis-basic", {
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
})
