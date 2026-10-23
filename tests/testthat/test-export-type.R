test_that("detects every example export type", {
  types <- vapply(
    tidymst_example(),
    \(f) mst_export_type(tidymst_example(f)),
    character(1)
  )
  expect_equal(
    unname(types),
    c(
      "compare_chart",
      "compare_chart",
      "dose_response_flat",
      "dose_response_grouped",
      "traces",
      "capillary_scan",
      "compare_chart",
      "compare_grid"
    )
  )
})

test_that("errors informatively on bad input", {
  expect_snapshot(error = TRUE, {
    mst_export_type(1)
    mst_export_type("missing.xlsx")
    read_mst_traces(tidymst_example("dsnppr10_compare-grid.xlsx"))
  })
})
