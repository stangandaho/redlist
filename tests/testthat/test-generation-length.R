test_that("mean_parent returns the mean parental age", {
  parents <- data.frame(age = c(5, 5, 3, 3, 4, 6, 6, 4, 5))
  expect_equal(
    rl_generation_length(parents, "mean_parent", age = age),
    mean(parents$age)
  )
})

test_that("mean_reproduction from a life table reproduces the IUCN calculator", {
  life_table <- data.frame(
    age = 0:19,
    lx = c(1, 0.1, rep(0.01, 17), 0),
    mx = c(0, 0, 0, rep(30, 16), 0)
  )
  expect_equal(
    rl_generation_length(life_table, "mean_reproduction",
                         age = age, lx = lx, mx = mx),
    10.5, tolerance = 1e-6
  )
})

test_that("mean_reproduction event form is the mean age of breeding", {
  cohort <- data.frame(age = c(5, 5, 3, 8, 5, 6, 3, 8, 9, 4))
  expect_equal(
    rl_generation_length(cohort, "mean_reproduction", age = age),
    mean(cohort$age)
  )
})

test_that("half_reproduction returns the weighted median age", {
  one <- data.frame(age = c(2, 3, 4))
  expect_equal(
    rl_generation_length(one, "half_reproduction", age = age),
    3
  )
})

test_that("replacement returns a positive generation time", {
  life_table <- data.frame(
    age = 1:4,
    lx = c(1, 0.6, 0.3, 0.1),
    mx = c(0, 1.5, 2, 1)
  )
  gt <- rl_generation_length(life_table, "replacement",
                             age = age, lx = lx, mx = mx)
  expect_true(is.numeric(gt) && gt > 0)
})

test_that("mean_parent averages within years when year is supplied", {
  parents <- data.frame(
    age = c(4, 6, 5, 5),
    year = c(2000, 2000, 2001, 2001)
  )
  # yearly means are 5 and 5, averaged to 5
  expect_equal(
    rl_generation_length(parents, "mean_parent", age = age, year = year),
    5
  )
})

test_that("half_reproduction weights by output across individuals", {
  rep_data <- data.frame(
    mother = rep(c("m1", "m2"), each = 3),
    age = c(2, 3, 4, 2, 3, 4),
    n_offspring = c(2, 3, 2, 2, 2, 2)
  )
  gl <- rl_generation_length(rep_data, "half_reproduction",
                             age = age, id = mother, output = n_offspring)
  expect_true(is.numeric(gl) && gl >= 2 && gl <= 4)
})

test_that("mismatched or missing arguments raise clear errors", {
  # only one of lx/mx supplied
  lt <- data.frame(age = 1:3, lx = c(1, 0.5, 0.2), mx = c(0, 1, 2))
  expect_error(
    rl_generation_length(lt, "mean_reproduction", age = age, lx = lx)
  )
  # replacement without the required columns
  expect_error(
    rl_generation_length(lt, "replacement", age = age)
  )
})

test_that("missing required columns raise a clear error", {
  expect_error(
    rl_generation_length(data.frame(x = 1:3), "mean_parent", age = age)
  )
  expect_error(
    rl_generation_length(1:3, "mean_parent", age = age)
  )
})
