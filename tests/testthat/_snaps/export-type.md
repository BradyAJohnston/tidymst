# errors informatively on bad input

    Code
      mst_export_type(1)
    Condition
      Error in `mst_export_type()`:
      ! `path` must be a single string, not the number 1.
    Code
      mst_export_type("missing.xlsx")
    Condition
      Error in `mst_export_type()`:
      ! 'missing.xlsx' doesn't exist.
    Code
      read_mst_traces(nanotempr_example("dsnppr10_compare-grid.xlsx"))
    Condition
      Error in `read_mst_traces()`:
      ! `path` must be a "traces" export, not "compare_grid".
      i Use `read_mst()` to pick a reader automatically.

