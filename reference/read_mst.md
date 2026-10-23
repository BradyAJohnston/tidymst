# Read a MO.Affinity Analysis export

`read_mst()` detects the type of export with
[`mst_export_type()`](https://bradyajohnston.github.io/tidymst/reference/mst_export_type.md)
and reads its main table:

## Usage

``` r
read_mst(path)
```

## Arguments

- path:

  Path to an `.xlsx` file exported from MO.Affinity Analysis, or a
  `.moc` or `.nta` project file.

## Value

A tibble.

## Details

- MST Traces:
  [`read_mst_traces()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_traces.md).

- Capillary Scan:
  [`read_mst_capillary_scan()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_capillary_scan.md).

- Compare Results (Chart) and Dose-Response (Grouped and Flat):
  [`read_mst_dose_response()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_dose_response.md).

- Compare Results (Grid):
  [`read_mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_fit.md).

- MO.Control (`.moc`) and MO.Affinity Analysis (`.nta`) project files:
  [`read_mst_traces()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_traces.md).

## Project files

MO.Control (`.moc`) and MO.Affinity Analysis (`.nta`) save projects as
SQLite databases, which hold everything the Excel exports are made from.
[`read_mst_traces()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_traces.md),
[`read_mst_capillary_scan()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_capillary_scan.md)
and
[`read_mst_metadata()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_metadata.md)
read both kinds of project;
[`read_mst_dose_response()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_dose_response.md)
and
[`read_mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_fit.md)
read MO.Affinity Analysis projects, which include the analysis. They
return the same columns as for the Excel exports, with these
differences:

- An `analysis_set` column names the analysis set, as a project can hold
  several. A trace in more than one analysis set appears once for each.
  MO.Control projects have no analysis, so `analysis_set`, `merge_set`
  and `included` are missing, and `run` is named as MO.Affinity Analysis
  would name it.

- Traces also have `fluorescence_raw`, the fluorescence in raw counts.
  `fluorescence` is normalised to the mean before the laser switches on,
  which is within about 0.2% of MO.Affinity Analysis's normalisation.

- Measurement times are in UTC (the Excel exports use local time), and
  `temperature` is the measured temperature in degrees Celsius.

- `mst_power` is a percentage, such as `"40%"`, rather than a label such
  as `"Medium"`, and `excitation_type` is not available.

- The fits from
  [`read_mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_fit.md)
  are those saved in the project, which may differ from an export made
  at another time. They include each parameter's standard error as
  reported by MO.Affinity Analysis (`*_std_error`), and `fixed` lists
  any parameters that were fixed.

Fit curves
([`read_mst_fit_curve()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_fit_curve.md))
are not read from projects; calculate them with
[`mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/mst_fit.md)
and
[`mst_curve()`](https://bradyajohnston.github.io/tidymst/reference/mst_curve.md).

## See also

[`read_mst_metadata()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_metadata.md)
for the file-level header, and
[`read_mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_fit.md)
and
[`read_mst_fit_curve()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_fit_curve.md)
for the fits included in Compare Results and Dose-Response (Grouped)
exports.

## Examples

``` r
read_mst(tidymst_example("dppr10-cy5_dose-response-flat.xlsx"))
#> # A tibble: 48 × 25
#>    merge_set       run              capillary target target_concentration ligand
#>    <chr>           <chr>                <int> <chr>                 <dbl> <chr> 
#>  1 dPPR10-Cy5 Tray Run atpH-fl_50_…         1 atpH-…           0.00000005 dPPR1…
#>  2 dPPR10-Cy5 Tray Run atpH-fl_50_…         2 atpH-…           0.00000005 dPPR1…
#>  3 dPPR10-Cy5 Tray Run atpH-fl_50_…         3 atpH-…           0.00000005 dPPR1…
#>  4 dPPR10-Cy5 Tray Run atpH-fl_50_…         4 atpH-…           0.00000005 dPPR1…
#>  5 dPPR10-Cy5 Tray Run atpH-fl_50_…         5 atpH-…           0.00000005 dPPR1…
#>  6 dPPR10-Cy5 Tray Run atpH-fl_50_…         6 atpH-…           0.00000005 dPPR1…
#>  7 dPPR10-Cy5 Tray Run atpH-fl_50_…         7 atpH-…           0.00000005 dPPR1…
#>  8 dPPR10-Cy5 Tray Run atpH-fl_50_…         8 atpH-…           0.00000005 dPPR1…
#>  9 dPPR10-Cy5 Tray Run atpH-fl_50_…         9 atpH-…           0.00000005 dPPR1…
#> 10 dPPR10-Cy5 Tray Run atpH-fl_50_…        10 atpH-…           0.00000005 dPPR1…
#> # ℹ 38 more rows
#> # ℹ 19 more variables: ligand_concentration <dbl>, response_type <chr>,
#> #   response <dbl>, project <chr>, analysis_set <chr>, analysis_type <chr>,
#> #   evaluation_strategy <chr>, origin <chr>, measured_at <dttm>,
#> #   cold_start <dbl>, cold_end <dbl>, hot_start <dbl>, hot_end <dbl>,
#> #   mst_power <chr>, excitation_power <dbl>, temperature <dbl>,
#> #   exported_on <dttm>, bleaching_rate <dbl>, initial_fluorescence <dbl>

# A project file from MO.Affinity Analysis
read_mst(tidymst_example("dppr10-cy5.nta"))
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
