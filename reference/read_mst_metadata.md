# Read export metadata

Reads the header that MO.Affinity Analysis writes at the top of every
export: where the data came from, when it was exported, and (for most
exports) the analysis settings.

## Usage

``` r
read_mst_metadata(path)
```

## Arguments

- path:

  Path to an `.xlsx` file exported from MO.Affinity Analysis, or a
  `.moc` or `.nta` project file.

## Value

A tibble with one row. Columns include `software`, `project`,
`analysis_set`, `exported_from` and `exported_on`, and, when the export
has a single set of analysis settings, `analysis_type`,
`evaluation_strategy` and the cold and hot regions in seconds
(`cold_start`, `cold_end`, `hot_start`, `hot_end`).

For project files, it gives the `software` that wrote the file, the
`project` name, when it was created and updated, and the instrument's
`device_type` and `optics_type`. MO.Affinity Analysis projects have one
row for each analysis set, with its settings.

## Examples

``` r
read_mst_metadata(tidymst_example("dppr10-cy5_traces.xlsx"))
#> # A tibble: 1 × 13
#>   software               project comment project_path analysis_set exported_from
#>   <chr>                  <chr>   <chr>   <chr>        <chr>        <chr>        
#> 1 MO.Affinity Analysis … dPPR10… NA      "C:\\Dropbo… Analysis-Se… MST Traces   
#> # ℹ 7 more variables: exported_on <dttm>, analysis_type <chr>,
#> #   evaluation_strategy <chr>, cold_start <dbl>, cold_end <dbl>,
#> #   hot_start <dbl>, hot_end <dbl>
read_mst_metadata(tidymst_example("dppr10-cy5.nta"))
#> # A tibble: 1 × 13
#>   software           project created_at          updated_at          device_type
#>   <chr>              <chr>   <dttm>              <dttm>              <chr>      
#> 1 MO.Affinity Analy… dPPR10… 2018-11-21 03:30:26 2018-11-21 03:30:26 NT115nano  
#> # ℹ 8 more variables: optics_type <chr>, analysis_set <chr>,
#> #   analysis_type <chr>, evaluation_strategy <chr>, cold_start <dbl>,
#> #   cold_end <dbl>, hot_start <dbl>, hot_end <dbl>
```
