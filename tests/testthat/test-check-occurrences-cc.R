# Tests that exercise the CoordinateCleaner backed checks and the reporting
# paths. They need CoordinateCleaner and its reference data, and some reach the
# network, so they are skipped on CRAN.

benin_points <- function(n = 10, seed = 1) {
  set.seed(seed)
  data.frame(
    decimalLongitude = 2 + runif(n, 0, 0.4),
    decimalLatitude = 9 + runif(n, 0, 0.4),
    eventDate = "2020",
    institutionCode = rep(c("A", "B"), length.out = n),
    coordinateUncertaintyInMeters = 50,
    year = 2020,
    stringsAsFactors = FALSE
  )
}

test_that("a full run reports every status and prints without error", {
  skip_if_not_installed("CoordinateCleaner")
  skip_on_cran()

  occ <- benin_points(10)
  occ$decimalLongitude[2] <- occ$decimalLongitude[1]     # a full duplicate of row 1
  occ$decimalLatitude[2] <- occ$decimalLatitude[1]
  occ$institutionCode[2] <- occ$institutionCode[1]
  occ$coordinateUncertaintyInMeters[3:4] <- 60000        # two coarse (a warn)
  occ$decimalLongitude[9:10] <- NA                       # two rows dropped as invalid
  occ$decimalLatitude[9:10] <- NA
  # no countryCode column, so the country check is skipped

  rep <- suppressWarnings(suppressMessages(rl_check_occurrences(occ)))
  expect_s3_class(rep, "tbl_df")
  expect_equal(nrow(rep), 9)
  expect_true(all(c("pass", "warn", "fail", "skip") %in% rep$status))
})

test_that("terrestrial = FALSE skips the ocean check", {
  skip_if_not_installed("CoordinateCleaner")
  rep <- suppressWarnings(
    rl_check_occurrences(benin_points(8), checks = "ocean_points", terrestrial = FALSE)
  )
  expect_equal(rep$status[rep$check == "ocean_points"], "skip")
})

test_that("country and ocean checks flag bad coordinates", {
  skip_if_not_installed("CoordinateCleaner")
  skip_on_cran()

  occ <- benin_points(10)
  occ$countryCode <- "BJ"
  occ$decimalLongitude[1] <- 60      # a point far outside Benin
  occ$decimalLatitude[1] <- 50
  rep <- suppressWarnings(rl_check_occurrences(occ, checks = c("country", "ocean_points")))
  expect_true(rep$n_flagged[rep$check == "country"] >= 1)
})

test_that("correct warns when it removes more than half the records", {
  # five identical rows: four are duplicates, so correcting removes 80 percent
  occ <- benin_points(1)[rep(1, 5), ]
  expect_warning(
    clean <- rl_check_occurrences(occ, checks = "duplicates", correct = "duplicates"),
    "more than half", ignore.case = TRUE
  )
  expect_equal(nrow(clean), 1)
})

test_that("a single institution and stale records are reported as failures", {
  occ <- benin_points(6)
  occ$institutionCode <- "A"
  occ$year <- 1985
  occ$eventDate <- "1985"
  rep <- rl_check_occurrences(occ, checks = c("institution_diversity", "recency"))
  expect_equal(rep$status[rep$check == "institution_diversity"], "fail")
  expect_equal(rep$status[rep$check == "recency"], "fail")
})

test_that("checks needing CoordinateCleaner are skipped when it is absent", {
  skip_if(requireNamespace("CoordinateCleaner", quietly = TRUE),
          "CoordinateCleaner is installed")
  rep <- rl_check_occurrences(benin_points(6), checks = "outliers")
  expect_equal(rep$status[rep$check == "outliers"], "skip")
})
