test_that("plots build", {
  skip_if_not_installed("ggplot2")
  traces <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
  doses <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_compare-fnorm.xlsx"
  ))
  doses <- dplyr::filter(doses, target == "atpH-fl")
  fits <- mst_fit(doses, .by = target)

  expect_s3_class(mst_plot_traces(traces), "ggplot")
  plot <- mst_plot_dose_response(doses, fits, colour = target)
  expect_s3_class(plot, "ggplot")
  expect_length(ggplot2::ggplot_build(plot)$data, 3)
})
