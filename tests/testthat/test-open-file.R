# rl_open_file() opens a file in the system editor, so we only test the
# input-validation branch that fails before any file or editor is touched.

test_that("rl_open_file rejects an unknown scope", {
  expect_error(rl_open_file(scope = "somewhere"))
})

test_that("rl_open_file accepts only the documented scopes", {
  # match.arg partial-matches, so a clearly invalid value must error
  expect_error(rl_open_file(scope = "usr-typo"))
})
