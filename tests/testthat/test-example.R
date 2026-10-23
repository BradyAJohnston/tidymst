test_that("nanotempr_example() lists and finds files", {
  expect_length(nanotempr_example(), 8)
  expect_match(
    nanotempr_example("dppr10-cy5_traces.xlsx"),
    "extdata/dppr10-cy5_traces.xlsx$"
  )
  expect_snapshot(error = TRUE, nanotempr_example("missing.xlsx"))
})
