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

  Path to an `.xlsx` file exported from MO.Affinity Analysis.

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
```
