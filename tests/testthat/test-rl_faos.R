library(testthat)
library(httptest2)

test_that("rl_faos returns expected structure", {
  with_mock_dir("rl_faos-basic", {
    # Test listing all FAO regions
    all_regions <- rl_faos()
    expect_s3_class(all_regions, "tbl_df")
    expect_true(nrow(all_regions) > 0)
  })
})

test_that("rl_faos handles code parameter correctly", {
  with_mock_dir("rl_faos-code", {
    # Test with numeric code
    region_27_num <- rl_faos(code = 27)
    expect_s3_class(region_27_num, "tbl_df")

    # Test with character code
    region_27_char <- rl_faos(code = "27")
    expect_equal(region_27_num, region_27_char)

    # Test with multiple codes
    multi_regions <- rl_faos(code = c("21", "27"))
    expect_s3_class(multi_regions, "tbl_df")
  })
})

test_that("rl_faos handles other parameters", {
  with_mock_dir("rl_faos-params", {
    # Test with year parameter (numeric and character)
    recent_assessments_num <- rl_faos(code = 27, year_published = 2020)
    recent_assessments_char <- rl_faos(code = 27, year_published = "2020")
    expect_equal(recent_assessments_num, recent_assessments_char)

    # Test with pagination
    paged_results <- rl_faos(code = 27, page = 2)
    expect_s3_class(paged_results, "tbl_df")
  })
})

test_that("rl_faos handles edge cases", {
  with_mock_dir("rl_faos-edge", {
    # Test invalid code format
    expect_error(rl_faos(code = TRUE))
    expect_error(rl_faos(code = 999))
  })
})
