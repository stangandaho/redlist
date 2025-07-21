library(testthat)
library(httptest2)

test_that("rl_green_status returns expected output", {
  with_mock_dir("rl_green_status-basic", {
    result <- rl_green_status()
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
  })
})

test_that("rl_habitats basic functionality works", {
  with_mock_dir("rl_habitats-basic", {
    # Test listing all habitats
    all_habitats <- rl_habitats()
    expect_s3_class(all_habitats, "tbl_df")
    expect_true(nrow(all_habitats) > 0)

    # Test with numeric code
    desert_num <- rl_habitats(code = 8)
    expect_s3_class(desert_num, "tbl_df")

    # Test with character code
    desert_char <- rl_habitats(code = "8")
    expect_equal(desert_num, desert_char)
  })
})

test_that("rl_habitats handles parameters correctly", {
  with_mock_dir("rl_habitats-params", {
    # Test with year parameter
    forest <- rl_habitats(code = 1, year_published = 2020)
    expect_s3_class(forest, "tbl_df")

    # Test with other parameters
    complex_query <- rl_habitats(
      code = c(1, 8),
      latest = TRUE,
      page = 2,
      pad_with_na = TRUE
    )
    expect_s3_class(complex_query, "tbl_df")
  })
})

test_that("rl_habitats handles edge cases", {
  with_mock_dir("rl_habitats-edge", {
    # Test invalid inputs
    expect_error(rl_habitats(code = TRUE))

    # Test non-existent code
    expect_error(rl_habitats(code = 999))
  })
})
