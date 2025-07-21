library(testthat)
library(httptest2)

test_that("rl_comprehensive_groups basic functionality works", {
  with_mock_dir("rl_comprehensive_groups-basic", {
    # Test listing all groups (NULL case)
    all_groups <- rl_comprehensive_groups()
    expect_s3_class(all_groups, "tbl_df")
    expect_true(nrow(all_groups) > 0)

    # Test with valid group name
    amphibians <- rl_comprehensive_groups(name = "amphibians")
    expect_s3_class(amphibians, "tbl_df")
    expect_true(nrow(amphibians) > 0)
  })
})

test_that("rl_comprehensive_groups handles parameters correctly", {
  with_mock_dir("rl_comprehensive_groups-params", {
    # Test with numeric year range
    mammals_recent <- rl_comprehensive_groups(name = "mammals", year_published = 2024:2025)
    expect_s3_class(mammals_recent, "tbl_df")

    # Test with character year (should work same as numeric)
    mammals_char <- rl_comprehensive_groups(name = "mammals", year_published = "2024")
    expect_s3_class(mammals_char, "tbl_df")

    # Test with pagination
    paged_results <- rl_comprehensive_groups(name = "birds", page = 1:3)
    expect_s3_class(paged_results, "tbl_df")
  })
})

test_that("rl_comprehensive_groups handles edge cases", {
  with_mock_dir("rl_comprehensive_groups-edge", {
    # Test invalid group name
    expect_error(rl_comprehensive_groups(name = "nonexistent_group"))

    # Note: Invalid year doesn't throw error
    invalid_year <- rl_comprehensive_groups(name = "amphibians", year_published = "invalid")
    expect_s3_class(invalid_year, "tbl_df")
  })
})
