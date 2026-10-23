test_that("parse_concentration() handles units", {
  expect_equal(
    parse_concentration(c(
      "5e-08",
      "50 nM",
      "50nM",
      "1.5 µM",
      "2 uM",
      "3 mM",
      "1 M",
      "n/a"
    )),
    c(5e-8, 5e-8, 5e-8, 1.5e-6, 2e-6, 3e-3, 1, NA)
  )
})

test_that("parse_datetime() handles serials and text", {
  expect_equal(
    parse_datetime(c("43425.5", "2018-11-21 12:00:00.000", NA)),
    as.POSIXct(c("2018-11-21 12:00:00", "2018-11-21 12:00:00", NA), tz = "UTC")
  )
})

test_that("split_date_range() splits ranges", {
  expect_equal(
    split_date_range(c("a → b", "c")),
    list(start = c("a", "c"), end = c("b", NA))
  )
})

test_that("response_type() standardises names", {
  expect_equal(
    response_type(c(
      "FNorm",
      "Fnorm [‰]",
      "DeltaFNorm",
      "FractionBound",
      "Other"
    )),
    c("fnorm", "fnorm", "delta_fnorm", "fraction_bound", NA)
  )
})

test_that("clean_names() maps known keys and snake cases the rest", {
  expect_equal(
    clean_names(c("Merge-Set Name", "TargetConcentration", "New Field (x)")),
    c("merge_set", "target_concentration", "new_field_x")
  )
})
