# Calculate normalised fluorescence from MST traces

Fnorm is the ratio of the mean fluorescence in a "hot" window, while the
IR laser is on, to the mean fluorescence in a "cold" window just before
it, expressed in per mille. Recalculating Fnorm from
[`read_mst_traces()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_traces.md)
lets you choose the windows without going back to MO.Affinity Analysis.

## Usage

``` r
mst_fnorm(data, hot, cold = c(-1, 0))
```

## Arguments

- data:

  A data frame of traces, as returned by
  [`read_mst_traces()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_traces.md),
  with columns `time` and `fluorescence`.

- hot, cold:

  Start and end times of the hot and cold windows, in seconds, as
  numeric vectors of length 2. The hot window depends on how long the
  laser was on; look up the one used in MO.Affinity Analysis with
  [`read_mst_metadata()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_metadata.md).

## Value

A tibble with one row per capillary, with the columns of `data` other
than `time` and `fluorescence`, plus `response_type` (always `"fnorm"`)
and `response`, the Fnorm in per mille. This is the same form as
[`read_mst_dose_response()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_dose_response.md),
ready for
[`mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/mst_fit.md).

## Details

Windows include their start and exclude their end, as MO.Affinity
Analysis does, so the results match its Fnorm for the same windows.

## Examples

``` r
traces <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
mst_fnorm(traces, hot = c(19, 20))
#> # A tibble: 80 × 16
#>    merge_set       run       capillary measured_at         capillary_type ligand
#>    <chr>           <chr>         <int> <dttm>              <chr>          <chr> 
#>  1 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  2 dPPR10-Cy5 Tray Run atpH…         2 2018-11-21 09:43:14 Unspecified c… dPPR1…
#>  3 dPPR10-Cy5 Tray Run atpH…         3 2018-11-21 09:43:57 Unspecified c… dPPR1…
#>  4 dPPR10-Cy5 Tray Run atpH…         4 2018-11-21 09:44:39 Unspecified c… dPPR1…
#>  5 dPPR10-Cy5 Tray Run atpH…         5 2018-11-21 09:45:22 Unspecified c… dPPR1…
#>  6 dPPR10-Cy5 Tray Run atpH…         6 2018-11-21 09:46:05 Unspecified c… dPPR1…
#>  7 dPPR10-Cy5 Tray Run atpH…         7 2018-11-21 09:46:47 Unspecified c… dPPR1…
#>  8 dPPR10-Cy5 Tray Run atpH…         8 2018-11-21 09:47:30 Unspecified c… dPPR1…
#>  9 dPPR10-Cy5 Tray Run atpH…         9 2018-11-21 09:48:13 Unspecified c… dPPR1…
#> 10 dPPR10-Cy5 Tray Run atpH…        10 2018-11-21 09:48:55 Unspecified c… dPPR1…
#> # ℹ 70 more rows
#> # ℹ 10 more variables: ligand_concentration <dbl>, target <chr>,
#> #   target_concentration <dbl>, mst_power <chr>, excitation_power <dbl>,
#> #   excitation_type <chr>, thermostat_setpoint <chr>, included <lgl>,
#> #   response_type <chr>, response <dbl>

# Use a shorter hot window, excluding outliers
traces |>
  dplyr::filter(included) |>
  mst_fnorm(hot = c(1.5, 2.5))
#> # A tibble: 79 × 16
#>    merge_set       run       capillary measured_at         capillary_type ligand
#>    <chr>           <chr>         <int> <dttm>              <chr>          <chr> 
#>  1 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  2 dPPR10-Cy5 Tray Run atpH…         2 2018-11-21 09:43:14 Unspecified c… dPPR1…
#>  3 dPPR10-Cy5 Tray Run atpH…         3 2018-11-21 09:43:57 Unspecified c… dPPR1…
#>  4 dPPR10-Cy5 Tray Run atpH…         4 2018-11-21 09:44:39 Unspecified c… dPPR1…
#>  5 dPPR10-Cy5 Tray Run atpH…         5 2018-11-21 09:45:22 Unspecified c… dPPR1…
#>  6 dPPR10-Cy5 Tray Run atpH…         6 2018-11-21 09:46:05 Unspecified c… dPPR1…
#>  7 dPPR10-Cy5 Tray Run atpH…         7 2018-11-21 09:46:47 Unspecified c… dPPR1…
#>  8 dPPR10-Cy5 Tray Run atpH…         8 2018-11-21 09:47:30 Unspecified c… dPPR1…
#>  9 dPPR10-Cy5 Tray Run atpH…         9 2018-11-21 09:48:13 Unspecified c… dPPR1…
#> 10 dPPR10-Cy5 Tray Run atpH…        10 2018-11-21 09:48:55 Unspecified c… dPPR1…
#> # ℹ 69 more rows
#> # ℹ 10 more variables: ligand_concentration <dbl>, target <chr>,
#> #   target_concentration <dbl>, mst_power <chr>, excitation_power <dbl>,
#> #   excitation_type <chr>, thermostat_setpoint <chr>, included <lgl>,
#> #   response_type <chr>, response <dbl>
```
