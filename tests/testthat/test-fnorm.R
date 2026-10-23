test_that("mst_fnorm() matches MO.Affinity Analysis", {
  traces <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
  flat <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))

  fnorm <- mst_fnorm(traces, hot = c(19, 20))
  joined <- dplyr::inner_join(fnorm, flat, by = c("run", "capillary"))

  expect_equal(nrow(fnorm), 80)
  expect_equal(nrow(joined), 48)
  expect_equal(joined$response.x, joined$response.y, tolerance = 1e-6)
  expect_equal(unique(fnorm$response_type), "fnorm")
})

test_that("mst_fnorm() validates windows", {
  traces <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))

  expect_snapshot(error = TRUE, {
    mst_fnorm(traces)
    mst_fnorm(traces, hot = c(20, 19))
    mst_fnorm(traces, hot = c(100, 101))
    mst_fnorm(data.frame(x = 1), hot = c(1, 2))
  })
})
