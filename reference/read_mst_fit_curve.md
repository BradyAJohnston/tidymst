# Read fitted binding curves

Reads the curves MO.Affinity Analysis fitted to each merge set, from the
`Fit-Values` sheet of Compare Results (Chart) and Dose-Response
(Grouped) exports.

## Usage

``` r
read_mst_fit_curve(path)
```

## Arguments

- path:

  Path to an `.xlsx` file exported from MO.Affinity Analysis.

## Value

A tibble with one row per point on each curve, with columns `series`,
`merge_set`, `target`, `ligand_concentration`, `fnorm`, `response_type`
and `response`. `response` is the curve in the units the data was
exported in (see `response_type`); `fnorm` is the same curve as Fnorm.
Some exports leave the curves empty, giving a tibble with no rows.

## Examples

``` r
read_mst_fit_curve(tidymst_example("dsnppr10_compare-delta-fnorm.xlsx"))
#> # A tibble: 300 × 7
#>    series merge_set     target ligand_concentration fnorm response_type response
#>     <int> <chr>         <chr>                 <dbl> <dbl> <chr>            <dbl>
#>  1      1 dsnPPR10 RNA… RNAat…           0.00000223  841. delta_fnorm      -220.
#>  2      1 dsnPPR10 RNA… RNAat…           0.00000207  841. delta_fnorm      -220.
#>  3      1 dsnPPR10 RNA… RNAat…           0.00000192  841. delta_fnorm      -219.
#>  4      1 dsnPPR10 RNA… RNAat…           0.00000179  841. delta_fnorm      -219.
#>  5      1 dsnPPR10 RNA… RNAat…           0.00000166  841. delta_fnorm      -219.
#>  6      1 dsnPPR10 RNA… RNAat…           0.00000154  841. delta_fnorm      -219.
#>  7      1 dsnPPR10 RNA… RNAat…           0.00000143  841. delta_fnorm      -219.
#>  8      1 dsnPPR10 RNA… RNAat…           0.00000133  842. delta_fnorm      -219.
#>  9      1 dsnPPR10 RNA… RNAat…           0.00000123  842. delta_fnorm      -219.
#> 10      1 dsnPPR10 RNA… RNAat…           0.00000115  842. delta_fnorm      -219.
#> # ℹ 290 more rows
```
