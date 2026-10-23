# Read MST traces

Reads an MST Traces export: the fluorescence of each capillary over
time, before and while the IR laser heats it. Normalised fluorescence
(Fnorm) can be recalculated from the traces with
[`mst_fnorm()`](https://bradyajohnston.github.io/tidymst/reference/mst_fnorm.md).

## Usage

``` r
read_mst_traces(path)
```

## Arguments

- path:

  Path to an `.xlsx` file exported from MO.Affinity Analysis.

## Value

A tibble with one row per time point per capillary. Alongside the sample
and measurement settings of each capillary, it has columns:

- `included`: `FALSE` if the capillary was marked as an outlier.

- `time`: time in seconds relative to the laser switching on.

- `fluorescence`: fluorescence, normalised by MO.Affinity Analysis.

Concentrations are molar.

## Examples

``` r
read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
#> # A tibble: 29,415 × 16
#>    merge_set       run       capillary measured_at         capillary_type ligand
#>    <chr>           <chr>         <int> <dttm>              <chr>          <chr> 
#>  1 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  2 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  3 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  4 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  5 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  6 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  7 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  8 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#>  9 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#> 10 dPPR10-Cy5 Tray Run atpH…         1 2018-11-21 09:42:32 Unspecified c… dPPR1…
#> # ℹ 29,405 more rows
#> # ℹ 10 more variables: ligand_concentration <dbl>, target <chr>,
#> #   target_concentration <dbl>, mst_power <chr>, excitation_power <dbl>,
#> #   excitation_type <chr>, thermostat_setpoint <chr>, included <lgl>,
#> #   time <dbl>, fluorescence <dbl>
```
