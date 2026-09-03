make_occ <- function() {
  data.frame(
    decimalLongitude = c(2.1234, 2.1234, 2.5312, 3.0725, 2.7654, 2.9481),
    decimalLatitude = c(9.1234, 9.1234, 9.5187, 9.0432, 9.3061, 9.8123),
    eventDate = c("2020", "2020", "2019", "2018", "2021", "2022"),
    institutionCode = c("A", "A", "B", "C", "B", "A"),
    coordinateUncertaintyInMeters = c(50, 50, 50, 60000, 50, 50),
    year = c(2020, 2020, 2019, 2018, 2021, 2022)
  )
}

non_cc <- c("duplicates", "coordinate_precision", "unique_localities",
            "recency", "institution_diversity")

test_that("a report is returned with one row per requested check", {
  rep <- rl_check_occurrences(make_occ(), checks = non_cc)
  expect_s3_class(rep, "tbl_df")
  expect_setequal(rep$check, non_cc)
  expect_true(all(rep$status %in% c("pass", "warn", "fail", "skip")))
})

test_that("the duplicates check finds and removes duplicate rows", {
  rep <- rl_check_occurrences(make_occ(), checks = "duplicates")
  expect_equal(rep$n_flagged[rep$check == "duplicates"], 1)

  clean <- rl_check_occurrences(make_occ(), checks = "duplicates", correct = "duplicates")
  expect_s3_class(clean, "data.frame")
  expect_equal(nrow(clean), nrow(make_occ()) - 1)
  expect_false(is.null(attr(clean, "report")))
})

test_that("coordinate_precision uses the 2 km cell threshold", {
  # only the 60000 m record is coarser than the 2 km default
  rep <- rl_check_occurrences(make_occ(), checks = "coordinate_precision")
  expect_equal(rep$n_flagged[rep$check == "coordinate_precision"], 1)
})

test_that("correct = TRUE leaves coordinate_precision in place", {
  clean <- rl_check_occurrences(make_occ(), checks = non_cc, correct = TRUE)
  # duplicates removed (1), the imprecise record kept
  expect_equal(nrow(clean), nrow(make_occ()) - 1)
})

test_that("unknown checks are rejected", {
  expect_error(rl_check_occurrences(make_occ(), checks = "banana"))
})

test_that("the outlier check flags a distant point when CoordinateCleaner is available", {
  skip_if_not_installed("CoordinateCleaner")
  set.seed(1)
  cluster <- data.frame(
    decimalLongitude = 2 + runif(12, 0, 0.5),
    decimalLatitude = 9 + runif(12, 0, 0.5),
    eventDate = "2020", institutionCode = "A",
    coordinateUncertaintyInMeters = 50, year = 2020
  )
  outlier <- data.frame(
    decimalLongitude = 40, decimalLatitude = 50,
    eventDate = "2020", institutionCode = "A",
    coordinateUncertaintyInMeters = 50, year = 2020
  )
  occ <- rbind(cluster, outlier)
  clean <- suppressWarnings(rl_check_occurrences(occ, checks = "outliers", correct = "outliers"))
  expect_lt(nrow(clean), nrow(occ))
})
