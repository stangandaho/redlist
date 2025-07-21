library(testthat)
library(httptest2)

test_that("rl_red_list_categories basic functionality works", {
  with_mock_dir("rl_red_list_categories-basic", {
    # Test listing all categories
    all_cats <- rl_red_list_categories()
    expect_s3_class(all_cats, "tbl_df")
    expect_true(nrow(all_cats) > 0)

    # Test with single category code
    cr_species <- rl_red_list_categories(code = "CR")
    expect_s3_class(cr_species, "tbl_df")
    expect_true(nrow(cr_species) > 0)

    # Test with multiple categories
    multi_cats <- rl_red_list_categories(code = c("CR", "EN"))
    expect_s3_class(multi_cats, "tbl_df")
    expect_true(nrow(multi_cats) > nrow(cr_species))
  })
})

test_that("rl_red_list_categories handles parameters correctly", {
  with_mock_dir("rl_red_list_categories-params", {
    # Test with year parameter
    recent_vu <- rl_red_list_categories(code = "VU", year_published = 2020)
    expect_s3_class(recent_vu, "tbl_df")

    # Test with other parameters
    complex_query <- rl_red_list_categories(
      code = "EN",
      latest = TRUE,
      page = 2,
      pad_with_na = TRUE
    )
    expect_s3_class(complex_query, "tbl_df")
  })
})

test_that("rl_red_list_categories handles edge cases", {
  with_mock_dir("rl_red_list_categories-edge", {
    # Test invalid inputs
    expect_error(rl_red_list_categories(code = 1))  # Must be character
    expect_error(rl_red_list_categories(code = "XX"))  # Invalid category

    # Test empty result
    empty_res <- rl_red_list_categories(code = "CR", year_published = 2100)
    expect_s3_class(empty_res, "tbl_df")
  })
})
