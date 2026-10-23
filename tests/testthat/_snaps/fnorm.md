# mst_fnorm() validates windows

    Code
      mst_fnorm(traces)
    Condition
      Error in `mst_fnorm()`:
      ! `hot` is absent but must be supplied.
    Code
      mst_fnorm(traces, hot = c(20, 19))
    Condition
      Error in `mst_fnorm()`:
      ! `hot` must be a numeric vector `c(start, end)` with `start` before `end`.
    Code
      mst_fnorm(traces, hot = c(100, 101))
    Condition
      Error in `mst_fnorm()`:
      ! `hot` must contain at least one time point.
      i Times range from -3.58 to 23.8 s.
    Code
      mst_fnorm(data.frame(x = 1), hot = c(1, 2))
    Condition
      Error in `mst_fnorm()`:
      ! `data` must have columns time and fluorescence.

