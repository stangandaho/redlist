library(testthat)
library(httptest2)

test_that("rl_biogeographical_realms basic functionality works", {
  with_mock_dir("rl_biogeographical_realms-basic", {
    # Test listing all realms (NULL case)
    all_realms <- rl_biogeographical_realms()
    expect_s3_class(all_realms, "tbl_df")
    expect_true(nrow(all_realms) > 0)

    # Test with numeric code
    realm0_num <- rl_biogeographical_realms(code = 0)
    expect_s3_class(realm0_num, "tbl_df")

    # Test with character code
    realm0_char <- rl_biogeographical_realms(code = "0")
    expect_s3_class(realm0_char, "tbl_df")
  })
})

test_that("rl_biogeographical_realms handles parameters correctly", {
  with_mock_dir("rl_biogeographical_realms-params", {
    # Test with numeric year range
    recent_realms <- rl_biogeographical_realms(code = 0, year_published = 2021)
    expect_s3_class(recent_realms, "tbl_df")

    # Test with character year (should work)
    recent_char <- rl_biogeographical_realms(code = 0, year_published = "2020")
    expect_s3_class(recent_char, "tbl_df")

    # Test with other parameters
    complex_query <- rl_biogeographical_realms(
      code = 0,
      latest = TRUE,
      page = 1,
      pad_with_na = TRUE
    )
    expect_s3_class(complex_query, "tbl_df")
  })
})

test_that("rl_biogeographical_realms handles edge cases", {
  with_mock_dir("rl_biogeographical_realms-edge", {
    # Test invalid year doesn't throw error
    invalid_year <- rl_biogeographical_realms(code = 0, year_published = "invalid")
    expect_s3_class(invalid_year, "tbl_df")

    # Test non-existent code
    empty_result <- rl_biogeographical_realms(code = 999)
    expect_s3_class(empty_result, "tbl_df")
  })
})
