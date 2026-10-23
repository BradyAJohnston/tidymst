# Detect the type of a MO.Affinity Analysis export

MO.Affinity Analysis records which view an export was made from in its
`Exported from:` field. `mst_export_type()` reads that field and returns
a short identifier, which
[`read_mst()`](https://bradyajohnston.github.io/tidymst/reference/read_mst.md)
uses to pick a reader.

## Usage

``` r
mst_export_type(path)
```

## Arguments

- path:

  Path to an `.xlsx` file exported from MO.Affinity Analysis.

## Value

A string, one of:

- `"traces"`: MST Traces, including the Raw Data Inspection variant.

- `"capillary_scan"`: Capillary Scan.

- `"compare_chart"`: Compare Results (Chart).

- `"compare_grid"`: Compare Results (Grid).

- `"dose_response_grouped"`: Dose-Response (Grouped).

- `"dose_response_flat"`: Dose-Response (Flat).

## Examples

``` r
mst_export_type(tidymst_example("dppr10-cy5_traces.xlsx"))
#> [1] "traces"
mst_export_type(tidymst_example("dppr10-cy5_compare-fnorm.xlsx"))
#> [1] "compare_chart"
```
