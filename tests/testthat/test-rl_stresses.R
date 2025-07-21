library(testthat)
library(httptest2)

test_that("rl_stresses works as expected", {
  with_mock_dir("rl_stresses-basic", {
    # Test listing all stress categories
    all_stresses <- rl_stresses()
    expect_s3_class(all_stresses, "tbl_df")
    expect_true(nrow(all_stresses) > 0)

    # Test with numeric code
    res_num <- rl_stresses(code = 1)
    expect_s3_class(res_num, "tbl_df")

    # Test with character code
    res_char <- rl_stresses(code = "1")
    expect_equal(res_num, res_char)

    # Test with compound code
    res_compound <- rl_stresses(code = "2_1")
    expect_s3_class(res_compound, "tbl_df")

    # Test with year parameter
    res_year <- rl_stresses(code = 1, year_published = 2020)
    expect_s3_class(res_year, "tbl_df")

    # Test with multiple codes
    res_multi <- rl_stresses(code = c(1, "2_1"))
    expect_s3_class(res_multi, "tbl_df")
  })
})

test_that("rl_stresses handles edge cases", {
  with_mock_dir("rl_stresses-edge", {
    # Test invalid inputs
    expect_error(rl_stresses(code = TRUE))
  })
})
