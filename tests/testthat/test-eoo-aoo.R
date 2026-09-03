test_that("rl_aoo counts occupied 2 km cells", {
  skip_if_not_installed("sf")
  # Two points about 5 km apart fall in two separate 2 km cells.
  two <- data.frame(longitude = c(0, 0), latitude = c(0, 0.045))
  a <- rl_aoo(two)
  expect_s3_class(a, "sf")
  expect_equal(a$n_occupied_cells, 2L)
  expect_equal(a$area_km2, 8)
  expect_equal(a$cell_size_km, 2)
  expect_equal(as.character(sf::st_geometry_type(a)), "MULTIPOLYGON")
})

test_that("rl_aoo flags the criterion B2 band", {
  skip_if_not_installed("sf")
  # A single point occupies one 4 km2 cell, below the CR threshold of 10 km2.
  one <- data.frame(longitude = 0, latitude = 0)
  expect_equal(rl_aoo(one)$category_b2, "CR")
})

test_that("rl_eoo measures the convex hull area", {
  skip_if_not_installed("sf")
  # A one degree box at the equator is about 12300 km2.
  box <- data.frame(longitude = c(0, 1, 1, 0), latitude = c(0, 0, 1, 1))
  e <- rl_eoo(box)
  expect_s3_class(e, "sf")
  expect_equal(as.character(sf::st_geometry_type(e)), "POLYGON")
  expect_equal(e$area_km2, 12300, tolerance = 100)
})

test_that("rl_eoo is undefined below three unique points", {
  skip_if_not_installed("sf")
  two <- data.frame(longitude = c(1, 1), latitude = c(2, 2))
  expect_warning(e <- rl_eoo(two))
  expect_true(is.na(e$area_km2))
  expect_true(is.na(e$category_b1))
})

test_that("both metrics accept an sf object and keep the input CRS", {
  skip_if_not_installed("sf")
  df <- data.frame(longitude = c(2.1, 2.6, 3.0, 2.4), latitude = c(9.1, 9.5, 9.0, 9.8))
  pts <- sf::st_as_sf(df, coords = c("longitude", "latitude"), crs = 4326)
  expect_equal(sf::st_crs(rl_eoo(pts)), sf::st_crs(4326))
  expect_equal(sf::st_crs(rl_aoo(pts)), sf::st_crs(4326))
})
