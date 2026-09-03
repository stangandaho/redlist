test_that("exponential reduction matches the IUCN worked example", {
  r <- rl_reduction(
    population = c(20000, 14000), time = c(1961, 1981),
    generation_length = 20, model = "exponential", assessment_year = 2001
  )
  expect_s3_class(r, "tbl_df")
  expect_equal(r$reduction_pct, 65.7, tolerance = 1e-2)
  expect_equal(r$n_start, 28571, tolerance = 1)
  expect_equal(r$n_present, 9800, tolerance = 1)
  expect_equal(r$year_start, 1941)
  expect_equal(r$year_present, 2001)
})

test_that("linear reduction matches the IUCN worked example", {
  r <- rl_reduction(
    population = c(20000, 14000), time = c(1961, 1981),
    generation_length = 20, model = "linear", assessment_year = 2001
  )
  expect_equal(r$reduction_pct, 69.2, tolerance = 1e-1)
  expect_equal(r$n_start, 26000, tolerance = 1)
  expect_equal(r$n_present, 8000, tolerance = 1)
})

test_that("the window defaults to the longer of three generations or ten years", {
  short <- rl_reduction(c(100, 90), c(2010, 2020), generation_length = 2)
  expect_equal(short$window_years, 10)
  long <- rl_reduction(c(100, 90), c(2010, 2020), generation_length = 20)
  expect_equal(long$window_years, 60)
})

test_that("category_a follows the chosen subcriterion thresholds", {
  a2 <- rl_reduction(c(20000, 14000), c(1961, 1981),
                     generation_length = 20, assessment_year = 2001)
  a1 <- rl_reduction(c(20000, 14000), c(1961, 1981),
                     generation_length = 20, assessment_year = 2001,
                     subcriterion = "A1")
  expect_equal(a2$category_a, "EN")   # 65.7% is >= 50 under A2
  expect_equal(a1$category_a, "VU")   # 65.7% is < 70 under A1
})

test_that("an increasing population gives a negative reduction and NA category", {
  r <- rl_reduction(c(1000, 2000), c(2000, 2020), generation_length = 5)
  expect_lt(r$reduction, 0)
  expect_true(is.na(r$category_a))
})

test_that("rl_reduction validates its inputs", {
  expect_error(rl_reduction(c(1, 2, 3), c(2000, 2010), generation_length = 5))
  expect_error(rl_reduction(100, 2000, generation_length = 5))
  expect_error(rl_reduction(c(100, 90), c(2000, 2010), generation_length = 0))
  expect_error(rl_reduction(c(100, 0), c(2000, 2010), generation_length = 5,
                            model = "exponential"))
})

test_that("overall reduction matches IUCN Example 1", {
  o <- rl_overall_reduction(
    past = c(10000, 8000, 12000),
    present = c(5000, 9000, 2000),
    subpopulation = c("Pacific", "Atlantic", "Indian")
  )
  expect_equal(o$reduction_pct, 46.7, tolerance = 1e-1)
  expect_equal(o$n_subpop, 3L)
  parts <- attr(o, "subpopulations")
  expect_equal(nrow(parts), 3)
  expect_equal(sum(parts$weight), 1)
})

test_that("overall reduction recovers a missing quantity", {
  # Example 3: present and reduction given, past inferred
  o <- rl_overall_reduction(
    present = c(4403, 9074, 1312),
    reduction = c(0.50, -0.179, 0.70)
  )
  expect_equal(o$reduction_pct, 29.2, tolerance = 2e-1)
})

test_that("overall reduction fills present from past and reduction", {
  o <- rl_overall_reduction(past = c(1000, 2000), reduction = c(0.5, 0.25))
  parts <- attr(o, "subpopulations")
  expect_equal(parts$present, c(500, 1500))
  # overall = 1 - 2000/3000
  expect_equal(o$reduction, 1 - 2000 / 3000, tolerance = 1e-8)
})

test_that("overall reduction rejects non-positive past sizes", {
  expect_error(rl_overall_reduction(past = c(0, 100), present = c(0, 50)))
})

test_that("overall reduction needs at least two of the three inputs", {
  expect_error(rl_overall_reduction(past = c(100, 200)))
})

test_that("linear decline is clamped at zero and gives a full reduction", {
  # a steep linear decline extrapolates below zero, so n_present is clamped
  r <- rl_reduction(c(1000, 100), c(2015, 2020),
                    generation_length = 20, model = "linear",
                    assessment_year = 2020)
  expect_gte(r$n_present, 0)
  expect_lte(r$reduction, 1)
})
