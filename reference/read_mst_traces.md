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

  Path to an `.xlsx` file exported from MO.Affinity Analysis, or a
  `.moc` or `.nta` project file.

## Value

A tibble with one row per time point per capillary. Alongside the sample
and measurement settings of each capillary, it has columns:

- `included`: `FALSE` if the capillary was marked as an outlier.

- `time`: time in seconds relative to the laser switching on.

- `fluorescence`: fluorescence, normalised by MO.Affinity Analysis.

Concentrations are molar. Project files give some extra columns; see the
Project files section of
[`read_mst()`](https://bradyajohnston.github.io/tidymst/reference/read_mst.md).

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
read_mst_traces(tidymst_example("dppr10-cy5.nta"))
#> # A tibble: 29,415 × 18
#>    analysis_set    merge_set       run   capillary measured_at         mst_power
#>    <chr>           <chr>           <chr>     <int> <dttm>              <chr>    
#>  1 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#>  2 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#>  3 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#>  4 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#>  5 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#>  6 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#>  7 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#>  8 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#>  9 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#> 10 Analysis-Set #1 dPPR10-Cy5 Tray Run …         1 2018-11-21 01:42:32 40%      
#> # ℹ 29,405 more rows
#> # ℹ 12 more variables: excitation_power <dbl>, thermostat_setpoint <chr>,
#> #   temperature <dbl>, capillary_type <chr>, ligand <chr>,
#> #   ligand_concentration <dbl>, target <chr>, target_concentration <dbl>,
#> #   included <lgl>, time <dbl>, fluorescence <dbl>, fluorescence_raw <dbl>
```
