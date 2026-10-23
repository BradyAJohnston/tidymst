# Read capillary scans

Reads a Capillary Scan export: the raw fluorescence across the tray
before each measurement, which is used to check for sticking,
aggregation and pipetting errors.

## Usage

``` r
read_mst_capillary_scan(path)
```

## Arguments

- path:

  Path to an `.xlsx` file exported from MO.Affinity Analysis, or a
  `.moc` or `.nta` project file.

## Value

A tibble with one row per scan position per capillary. Alongside the
sample and measurement settings of each capillary, it has columns:

- `included`: `FALSE` if the capillary was marked as an outlier.

- `position`: position along the tray, in capillary index units.

- `fluorescence`: raw fluorescence counts.

Project files give some extra columns; see the Project files section of
[`read_mst()`](https://bradyajohnston.github.io/tidymst/reference/read_mst.md).

## Examples

``` r
read_mst_capillary_scan(tidymst_example("dppr10c2_capillary-scan.xlsx"))
#> # A tibble: 28,418 × 16
#>    merge_set run             capillary measured_at         capillary_type ligand
#>    <chr>     <chr>               <int> <dttm>              <chr>          <chr> 
#>  1 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#>  2 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#>  3 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#>  4 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#>  5 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#>  6 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#>  7 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#>  8 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#>  9 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#> 10 Initial   Run dPPR10C2_2…         1 2020-01-16 12:46:28 Unspecified c… RNAat…
#> # ℹ 28,408 more rows
#> # ℹ 10 more variables: ligand_concentration <dbl>, target <chr>,
#> #   target_concentration <dbl>, mst_power <chr>, excitation_power <dbl>,
#> #   excitation_type <chr>, thermostat_setpoint <chr>, included <lgl>,
#> #   position <dbl>, fluorescence <dbl>
read_mst_capillary_scan(tidymst_example("dppr10-cy5.nta"))
#> # A tibble: 23,689 × 16
#>    analysis_set   merge_set run   capillary measured_at         excitation_power
#>    <chr>          <chr>     <chr>     <int> <dttm>                         <dbl>
#>  1 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#>  2 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#>  3 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#>  4 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#>  5 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#>  6 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#>  7 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#>  8 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#>  9 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#> 10 Analysis-Set … dPPR10-C… Run …         1 2018-11-21 01:41:54               30
#> # ℹ 23,679 more rows
#> # ℹ 10 more variables: thermostat_setpoint <chr>, temperature <dbl>,
#> #   capillary_type <chr>, ligand <chr>, ligand_concentration <dbl>,
#> #   target <chr>, target_concentration <dbl>, included <lgl>, position <dbl>,
#> #   fluorescence <dbl>
```
