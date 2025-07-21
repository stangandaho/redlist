library(testthat)
library(httptest2)

test_that("rl_scopes basic functionality works", {
  with_mock_dir("rl_scopes-basic", {
    # Test listing all scopes
    all_scopes <- rl_scopes()
    expect_s3_class(all_scopes, "tbl_df")
    expect_true(nrow(all_scopes) > 0)

    # Test with numeric code
    global_num <- rl_scopes(code = 1)
    expect_s3_class(global_num, "tbl_df")

    # Test with character code
    global_char <- rl_scopes(code = "1")
    expect_equal(global_num, global_char)

    # Test with multiple codes
    multi_scopes <- rl_scopes(code = c(1, 2))
    expect_s3_class(multi_scopes, "tbl_df")
  })
})

test_that("rl_scopes handles parameters correctly", {
  with_mock_dir("rl_scopes-params", {
    # Test with numeric year range
    recent_assessments <- rl_scopes(code = 2, year_published = 2020:2023)
    expect_s3_class(recent_assessments, "tbl_df")

    # Test with other parameters
    complex_query <- rl_scopes(
      code = 1,
      latest = TRUE,
      page = 2
    )
    expect_s3_class(complex_query, "tbl_df")
  })
})

test_that("rl_scopes handles edge cases", {
  with_mock_dir("rl_scopes-edge", {
    # Test invalid inputs
    expect_error(rl_scopes(code = TRUE))
  })
})
