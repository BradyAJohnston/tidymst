# Get fitted model coefficients

Get fitted model coefficients

## Usage

``` r
mst_coefs(fits, conf_level = 0.95)
```

## Arguments

- fits:

  A tibble of fits from
  [`mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/mst_fit.md).

- conf_level:

  Confidence level of the intervals.

## Value

A tibble with one row per parameter per fit, with the grouping columns
of `fits` and:

- `model`: the model fitted.

- `term`: the parameter: `unbound`, `bound`, and `kd` and
  `target_concentration` for the Kd model or `ec50` and `hill` for the
  Hill model. A fixed `target_concentration` is not included.

- `estimate` and `std_error`: the estimate and its standard error.
  Concentrations are molar.

- `conf_low` and `conf_high`: the confidence interval, from the
  t-distribution. Concentrations are fitted on a log scale, so their
  intervals are calculated on that scale and are asymmetric, and their
  standard errors are approximate.

## Examples

``` r
doses <- read_mst_dose_response(
  tidymst_example("dppr10-cy5_dose-response-flat.xlsx")
)
fits <- mst_fit(doses, .by = target)
mst_coefs(fits)
#> # A tibble: 4 × 7
#>   target  model term                 estimate     std_error conf_low conf_high
#>   <chr>   <chr> <chr>                   <dbl>         <dbl>    <dbl>     <dbl>
#> 1 atpH-fl kd    unbound               1.09e+3 2.44           1.09e+3   1.10e+3
#> 2 atpH-fl kd    bound                 8.51e+2 3.98           8.43e+2   8.59e+2
#> 3 atpH-fl kd    kd                    1.47e-8 0.00000000557  6.88e-9   3.16e-8
#> 4 atpH-fl kd    target_concentration  1.13e-7 0.0000000138   8.86e-8   1.45e-7
```
