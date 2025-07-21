library(testthat)
library(httptest2)

test_that("rl_habitats basic functionality works", {
  with_mock_dir("rl_habitats-basic", {
    # Test listing all habitat codes
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
    # Test with numeric year
    forest_2020 <- rl_habitats(code = 1, year_published = 2020)
    expect_s3_class(forest_2020, "tbl_df")

    # Test with character year
    forest_char <- rl_habitats(code = 1, year_published = "2020")
    expect_equal(forest_2020, forest_char)

  })
})

test_that("rl_habitats handles edge cases", {
  with_mock_dir("rl_habitats-edge", {
    # Test invalid inputs
    expect_error(rl_habitats(code = TRUE))
    expect_error(rl_habitats(code = "invalid"))

    # Test non-existent code
    expect_error(rl_habitats(code = 999))
  })
})
