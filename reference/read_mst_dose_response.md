# Read dose-response data

Reads the response of each ligand concentration from a dose-response
export.

## Usage

``` r
read_mst_dose_response(path)
```

## Arguments

- path:

  Path to an `.xlsx` file exported from MO.Affinity Analysis, or a
  `.moc` or `.nta` project file.

## Value

A tibble with one row per concentration per series. It always has
columns `merge_set`, `target`, `target_concentration`, `ligand`,
`ligand_concentration`, `response_type` and `response`, followed by the
other settings in the export.

- `response_type` is one of `"fnorm"`, `"delta_fnorm"` or
  `"fraction_bound"`, depending on how the data was exported. Fnorm and
  delta Fnorm are in per mille.

- `series` numbers the merge sets in the order they appear in the
  export, to tell apart series that share a name. It matches `series` in
  [`read_mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_fit.md)
  and
  [`read_mst_fit_curve()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_fit_curve.md).

- `error` is the error of the mean response.

Concentrations are molar.

## Details

- Compare Results (Chart) and Dose-Response (Grouped) exports give the
  mean response of each concentration in each merge set, with its error.
  Capillaries marked as outliers are excluded.

- Dose-Response (Flat) exports give the Fnorm of every capillary. They
  do not record which capillaries were marked as outliers, so all are
  included; join to
  [`read_mst_traces()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_traces.md)
  by `run` and `capillary` to find them.

- MO.Affinity Analysis project files (`.nta`) give the Fnorm of every
  capillary, calculated with
  [`mst_fnorm()`](https://bradyajohnston.github.io/tidymst/reference/mst_fnorm.md)
  using the cold and hot regions of its analysis set, and whether it was
  included. See the Project files section of
  [`read_mst()`](https://bradyajohnston.github.io/tidymst/reference/read_mst.md).

Note that dates of measurement in Dose-Response (Flat) exports appear to
be in UTC, while other exports use the local time of the instrument
computer. Both are returned as recorded, labelled as UTC.

## Examples

``` r
read_mst_dose_response(tidymst_example("dppr10-cy5_compare-fnorm.xlsx"))
#> # A tibble: 32 × 22
#>    series merge_set      target target_concentration ligand ligand_concentration
#>     <int> <chr>          <chr>                 <dbl> <chr>                 <dbl>
#>  1      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.00000000011
#>  2      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.00000000021
#>  3      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.00000000043
#>  4      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.00000000085
#>  5      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.00000000171
#>  6      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.00000000342
#>  7      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.00000000684
#>  8      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.0000000137 
#>  9      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.0000000273 
#> 10      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1…        0.0000000547 
#> # ℹ 22 more rows
#> # ℹ 16 more variables: response_type <chr>, response <dbl>, error <dbl>,
#> #   measured_at <dttm>, measured_end <dttm>, capillary_type <chr>,
#> #   mst_power <chr>, excitation_power <dbl>, excitation_type <chr>,
#> #   thermostat_setpoint <chr>, analysis_type <chr>, evaluation_strategy <chr>,
#> #   cold_start <dbl>, cold_end <dbl>, hot_start <dbl>, hot_end <dbl>

read_mst_dose_response(
  tidymst_example("dppr10-cy5_dose-response-flat.xlsx")
)
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

read_mst_dose_response(tidymst_example("dppr10-cy5.nta"))
#> # A tibble: 80 × 21
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
#> # ℹ 70 more rows
#> # ℹ 15 more variables: ligand_concentration <dbl>, response_type <chr>,
#> #   response <dbl>, analysis_set <chr>, measured_at <dttm>, mst_power <chr>,
#> #   excitation_power <dbl>, thermostat_setpoint <chr>, temperature <dbl>,
#> #   capillary_type <chr>, included <lgl>, cold_start <dbl>, cold_end <dbl>,
#> #   hot_start <dbl>, hot_end <dbl>
```
