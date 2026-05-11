test_that("chunk rasters with different origins are aligned to a shared template", {
  r1 <- terra::rast(terra::ext(0, 2, 0, 2), resolution = 1, crs = "EPSG:4326")
  r2 <- terra::rast(terra::ext(0.2, 2.2, 0, 2), resolution = 1, crs = "EPSG:4326")
  terra::values(r1) <- 1:terra::ncell(r1)
  terra::values(r2) <- 11:(10 + terra::ncell(r2))
  names(r1) <- "signal"
  names(r2) <- "signal"

  merged <- CAVAanalytics:::.merge_chunk_rasters(
    list(r1, r2),
    verbose = FALSE,
    context = "test rasters"
  )

  expect_s4_class(merged, "SpatRaster")
  expect_equal(terra::origin(merged), terra::origin(r1))
  expect_equal(terra::res(merged), terra::res(r1))
  expect_equal(unname(as.vector(terra::ext(merged))), c(0, 3, 0, 2))
  expect_equal(names(merged), "signal")
  expect_true(any(!is.na(terra::values(merged))))
})

test_that("chunk merge drops NULL entries but errors when none remain", {
  r1 <- terra::rast(terra::ext(0, 2, 0, 2), resolution = 1, crs = "EPSG:4326")
  terra::values(r1) <- 1:terra::ncell(r1)
  names(r1) <- "signal"

  merged <- CAVAanalytics:::.merge_chunk_rasters(
    list(NULL, r1, NULL),
    verbose = FALSE,
    context = "test rasters"
  )

  expect_s4_class(merged, "SpatRaster")
  expect_equal(names(merged), "signal")

  expect_error(
    CAVAanalytics:::.merge_chunk_rasters(
      list(NULL, NULL),
      verbose = FALSE,
      context = "test rasters"
    ),
    "No valid chunk rasters were produced for merge"
  )
})
