library(testthat)
library(httptest2)

test_that("rl_family basic functionality works", {
  with_mock_dir("rl_family-basic", {
    # Test listing all families
    all_families <- rl_family()
    expect_s3_class(all_families, "tbl_df")
    expect_true(nrow(all_families) > 0)
    expect_true("family_names" %in% names(all_families))

    # Test with valid family name
    felidae <- rl_family(family_name = "Felidae")
    expect_s3_class(felidae, "tbl_df")
    expect_true(nrow(felidae) > 0)
  })
})

test_that("rl_family handles parameters correctly", {
  with_mock_dir("rl_family-params", {
    # Test with numeric year range
    canidae_recent <- rl_family(family_name = "Canidae", year_published = 2021:2022)
    expect_s3_class(canidae_recent, "tbl_df")

    # Test with character year
    canidae_char <- rl_family(family_name = "Canidae", year_published = "2020")
    expect_s3_class(canidae_char, "tbl_df")

    # Test with other parameters
    complex_query <- rl_family(
      family_name = "Ursidae",
      latest = TRUE,
      page = 2,
      pad_with_na = TRUE
    )
    expect_s3_class(complex_query, "tbl_df")
  })
})

test_that("rl_family handles edge cases", {
  with_mock_dir("rl_family-edge", {
    # Test non-existent family
    fake_family <- rl_family(family_name = "NonexistentFamily")
    expect_s3_class(fake_family, "tbl_df")
    expect_equal(nrow(fake_family), 1)

    # Test empty response handling
    empty_resp <- rl_family(family_name = "Felidae")
    expect_s3_class(empty_resp, "tbl_df")
  })
})
