library(testthat)
library(httptest2)

test_that("rl_systems basic functionality works", {
  with_mock_dir("rl_systems-basic", {
    # Test listing all systems
    all_systems <- rl_systems()
    expect_s3_class(all_systems, "tbl_df")
    expect_true(nrow(all_systems) > 0)

    # Test with numeric code
    terrestrial_num <- rl_systems(code = 0)
    expect_s3_class(terrestrial_num, "tbl_df")
    expect_true(nrow(terrestrial_num) > 0)

    # Test with character code
    terrestrial_char <- rl_systems(code = "0")
    expect_equal(terrestrial_num, terrestrial_char)

    # Test with multiple codes
    multi_systems <- rl_systems(code = c(0, 1))
    expect_s3_class(multi_systems, "tbl_df")
    expect_true(nrow(multi_systems) >= nrow(terrestrial_num))
  })
})

test_that("rl_systems handles parameters correctly", {
  with_mock_dir("rl_systems-params", {
    # Test with numeric year range
    marine_recent <- rl_systems(code = 2, year_published = 2021:2022)
    expect_s3_class(marine_recent, "tbl_df")

    # Test with character year
    marine_char_year <- rl_systems(code = "2", year_published = "2021")
    expect_s3_class(marine_char_year, "tbl_df")

    # Test with other parameters
    complex_query <- rl_systems(
      code = 1,
      latest = TRUE,
      page = 2,
      pad_with_na = TRUE
    )
    expect_s3_class(complex_query, "tbl_df")
    expect_false(any(is.na(complex_query)))
  })
})
