library(testthat)

test_that("rl_phylum basic functionality works", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test listing all phyla
  all_phyla <- rl_phylum()
  expect_s3_class(all_phyla, "tbl_df")
  expect_true(nrow(all_phyla) > 0)
  expect_true("phylum_names" %in% names(all_phyla))

  # Test with valid phylum name
  chordata <- rl_phylum(phylum_name = "Chordata")
  expect_s3_class(chordata, "tbl_df")
  expect_true(nrow(chordata) > 0)
})

test_that("rl_phylum handles parameters correctly", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  # Test with numeric year
  arthropoda_2020 <- rl_phylum(phylum_name = "Arthropoda", year_published = 2020)
  expect_s3_class(arthropoda_2020, "tbl_df")

  # Test with character year
  arthropoda_char <- rl_phylum(phylum_name = "Arthropoda", year_published = "2020")
  expect_equal(arthropoda_2020, arthropoda_char)

  # Test with other parameters
  complex_query <- rl_phylum(
    phylum_name = "Chordata",
    latest = TRUE,
    page = 2,
    pad_with_na = TRUE
  )
  expect_s3_class(complex_query, "tbl_df")
})

test_that("rl_phylum handles edge cases", {
  # Test non-existent phylum
  testthat::skip_on_cran()
  testthat::skip_if_offline()
  fake_phylum <- rl_phylum(phylum_name = "NonexistentPhylum")
  expect_s3_class(fake_phylum, "tbl_df")
})
