# errors informatively on unsupported project reads

    Code
      read_mst_traces(empty)
    Condition
      Error in `read_mst_traces()`:
      ! '<project>.moc' doesn't contain any measurements.
    Code
      read_mst_fit(control)
    Condition
      Error in `read_mst_fit()`:
      ! `path` must be a "compare_chart", "compare_grid", "dose_response_grouped", or "affinity_project" export, not "control_project".
      i Use `read_mst()` to pick a reader automatically.
    Code
      read_mst_fit_curve(tidymst_example("dppr10-cy5.nta"))
    Condition
      Error in `read_mst_fit_curve()`:
      ! `path` must be a "compare_chart" or "dose_response_grouped" export, not "affinity_project".
      i Use `read_mst()` to pick a reader automatically.

