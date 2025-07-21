library(testthat)
library(httptest2)

test_that("rl_population_trends basic functionality works", {
  with_mock_dir("rl_population_trends-basic", {
    # Test listing all trend categories
    all_trends <- rl_population_trends()
    expect_s3_class(all_trends, "tbl_df")
    expect_true(nrow(all_trends) > 0)

    # Test with numeric code
    decreasing_num <- rl_population_trends(code = 1)
    expect_s3_class(decreasing_num, "tbl_df")

    # Test with character code
    decreasing_char <- rl_population_trends(code = "1")
    expect_equal(decreasing_num, decreasing_char)

    # Test with multiple codes
    multi_trends <- rl_population_trends(code = c(1, 2))
    expect_s3_class(multi_trends, "tbl_df")
  })
})

test_that("rl_population_trends handles parameters correctly", {
  with_mock_dir("rl_population_trends-params", {
    # Test with numeric year
    recent_trends <- rl_population_trends(code = 2, year_published = 2020)
    expect_s3_class(recent_trends, "tbl_df")

    # Test with character year
    recent_trends_char <- rl_population_trends(code = 2, year_published = "2020")
    expect_equal(recent_trends, recent_trends_char)

    # Test with other parameters
    complex_query <- rl_population_trends(
      code = 3,  # Unknown trend
      latest = TRUE,
      page = 2,
      pad_with_na = TRUE
    )
    expect_s3_class(complex_query, "tbl_df")
  })
})

test_that("rl_population_trends handles edge cases", {
  with_mock_dir("rl_population_trends-edge", {
    # Test invalid inputs
    expect_error(rl_population_trends(code = TRUE))
    expect_error(rl_population_trends(code = "invalid"))

    # Test non-existent code
    expect_error(rl_population_trends(code = 999))
  })
})
