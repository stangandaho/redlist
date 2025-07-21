library(testthat)
library(httptest2)

test_that("rl_conservation_actions basic functionality works", {
  with_mock_dir("rl_conservation_actions-basic", {
    # Test listing all action codes (NULL case)
    all_actions <- rl_conservation_actions()
    expect_s3_class(all_actions, "tbl_df")
    expect_true(nrow(all_actions) > 0)

    # Test with numeric code
    action_1 <- rl_conservation_actions(code = 1)
    expect_s3_class(action_1, "tbl_df")

    # Test with character code
    action_1_char <- rl_conservation_actions(code = "1")
    expect_equal(action_1, action_1_char)
  })
})

test_that("rl_conservation_actions handles parameters correctly", {
  with_mock_dir("rl_conservation_actions-params", {
    # Test with numeric year range
    recent_actions <- rl_conservation_actions(code = 1, year_published = 2024:2025)
    expect_s3_class(recent_actions, "tbl_df")

    # Test with pagination
    paged_actions <- rl_conservation_actions(code = 1, page = 1:3)
    expect_s3_class(paged_actions, "tbl_df")
  })
})

test_that("rl_conservation_actions handles edge cases", {
  with_mock_dir("rl_conservation_actions-edge", {
    # Test invalid inputs
    expect_error(rl_conservation_actions(code = "invalid"))

    # Test non-existent code
    expect_error(rl_conservation_actions(code = 999))
  })
})
