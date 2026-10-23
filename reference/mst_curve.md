# Predict fitted binding curves

Predict fitted binding curves

## Usage

``` r
mst_curve(fits, n = 100)
```

## Arguments

- fits:

  A tibble of fits from
  [`mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/mst_fit.md).

- n:

  Number of points on each curve, spaced evenly on a log scale over the
  range of concentrations fitted.

## Value

A tibble with `n` rows per fit, with the grouping columns of `fits` and:

- The concentration, named as in
  [`mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/mst_fit.md)
  (`ligand_concentration` by default).

- `response`: the fitted response.

- `delta_fnorm`: the response relative to the unbound state.

- `fraction_bound`: the fraction of target bound.

## Examples

``` r
doses <- read_mst_dose_response(
  tidymst_example("dppr10-cy5_dose-response-flat.xlsx")
)
fits <- mst_fit(doses, .by = target)
mst_curve(fits)
#> # A tibble: 100 × 5
#>    target  ligand_concentration response delta_fnorm fraction_bound
#>    <chr>                  <dbl>    <dbl>       <dbl>          <dbl>
#>  1 atpH-fl             1.10e-10    1092.      -0.207       0.000859
#>  2 atpH-fl             1.22e-10    1092.      -0.230       0.000954
#>  3 atpH-fl             1.36e-10    1092.      -0.255       0.00106 
#>  4 atpH-fl             1.51e-10    1092.      -0.283       0.00118 
#>  5 atpH-fl             1.67e-10    1092.      -0.314       0.00131 
#>  6 atpH-fl             1.86e-10    1092.      -0.349       0.00145 
#>  7 atpH-fl             2.06e-10    1092.      -0.388       0.00161 
#>  8 atpH-fl             2.29e-10    1092.      -0.430       0.00179 
#>  9 atpH-fl             2.54e-10    1092.      -0.478       0.00198 
#> 10 atpH-fl             2.82e-10    1092.      -0.531       0.00220 
#> # ℹ 90 more rows
```
