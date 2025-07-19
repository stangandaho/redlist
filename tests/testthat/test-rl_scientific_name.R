test_that("rl_scientific_name handles errors correctly", {
  # Test missing required params
  expect_error(rl_scientific_name(species_name = "leo"))
  expect_error(rl_scientific_name(genus_name = "Panthera"))

  # Test invalid name formats
  expect_error(rl_scientific_name(genus_name = 123, species_name = "leo"))
  expect_error(rl_scientific_name(genus_name = "Panthera", species_name = TRUE))
})

test_that("rl_scientific_name handles non-existent taxa", {
  testthat::skip_on_cran()
  testthat::skip_if_offline()

  expect_error(rl_scientific_name(genus_name = "Nonexistentia",
                                  species_name = "imaginaris"))
})
