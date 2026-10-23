# mst_fit() warns when fits fail

    Code
      fits <- mst_fit(doses)
    Condition
      Warning:
      Failed to fit 1 of 1 group.

# mst_fit() validates arguments

    Code
      mst_fit(doses, model = "linear")
    Condition
      Error in `mst_fit()`:
      ! `model` must be one of "kd" or "hill", not "linear".
    Code
      mst_fit(doses, model = "hill", target_concentration = 1e-09)
    Condition
      Error in `mst_fit()`:
      ! `target_concentration` can only be used with `model = "kd"`.
    Code
      mst_fit(dplyr::group_by(doses, target), .by = target)
    Condition
      Error in `mst_fit()`:
      ! Can't supply `.by` when `data` is grouped.
    Code
      mst_coefs(doses)
    Condition
      Error in `mst_coefs()`:
      ! `fits` must be a tibble of fits from `mst_fit()`.

