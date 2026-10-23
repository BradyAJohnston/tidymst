test_that("tidymst_example() lists and finds files", {
  expect_length(tidymst_example(), 8)
  expect_match(
    tidymst_example("dppr10-cy5_traces.xlsx"),
    "extdata/dppr10-cy5_traces.xlsx$"
  )
  expect_snapshot(error = TRUE, tidymst_example("missing.xlsx"))
})
