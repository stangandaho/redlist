library(testthat)
library(httptest2)

test_that("rl_kingdoms basic functionality works", {
  with_mock_dir("rl_kingdoms-basic", {
    # Test listing all kingdoms
    all_kingdoms <- rl_kingdoms()
    expect_s3_class(all_kingdoms, "tbl_df")
    expect_true(nrow(all_kingdoms) > 0)

    # Test with valid kingdom name
    animalia <- rl_kingdoms(kingdom_name = "Animalia")
    expect_s3_class(animalia, "tbl_df")
    expect_true(nrow(animalia) > 0)
  })
})

test_that("rl_kingdoms handles parameters correctly", {
  with_mock_dir("rl_kingdoms-params", {
    # Test with numeric year
    plantae_2021 <- rl_kingdoms(kingdom_name = "Plantae", year_published = 2021)
    expect_s3_class(plantae_2021, "tbl_df")

    # Test with character year
    plantae_char <- rl_kingdoms(kingdom_name = "Plantae", year_published = "2021")
    expect_equal(plantae_2021, plantae_char)

    # Test with other parameters
    complex_query <- rl_kingdoms(
      kingdom_name = "Fungi",
      latest = TRUE,
      page = 2,
      pad_with_na = TRUE
    )
    expect_s3_class(complex_query, "tbl_df")
  })
})

test_that("rl_kingdoms handles edge cases", {
  with_mock_dir("rl_kingdoms-edge", {
    # Test non-existent kingdom
    fake_kingdom <- rl_kingdoms(kingdom_name = "NonexistentKingdom")
    expect_s3_class(fake_kingdom, "tbl_df")
    expect_equal(nrow(fake_kingdom), 1)

    # Test empty response handling
    empty_resp <- rl_kingdoms(kingdom_name = "Animalia", year_published = 2100)
    expect_s3_class(empty_resp, "tbl_df")
  })
})
