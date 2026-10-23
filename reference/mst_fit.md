# Fit binding models to dose-response data

Fits the binding models used by MO.Affinity Analysis by non-linear least
squares, with [`stats::nls()`](https://rdrr.io/r/stats/nls.html).

## Usage

``` r
mst_fit(
  data,
  model = c("kd", "hill"),
  concentration = ligand_concentration,
  response = response,
  target_concentration = NULL,
  .by = NULL
)
```

## Arguments

- data:

  A data frame with a row for each concentration, such as from
  [`read_mst_dose_response()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_dose_response.md)
  or
  [`mst_fnorm()`](https://bradyajohnston.github.io/tidymst/reference/mst_fnorm.md).
  If `data` is grouped with
  [`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html),
  each group is fitted separately.

- model:

  The model to fit, `"kd"` or `"hill"`. See the Models section.

- concentration, response:

  \<[`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  The columns of ligand concentration (molar) and response.

- target_concentration:

  For the Kd model, the target concentration in molar. If `NULL`, the
  default, it is estimated along with the other parameters, as
  MO.Affinity Analysis can do. If it is known, fixing it gives a more
  stable fit.

- .by:

  \<[`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html)\>
  Columns to group by, fitting each group separately. An alternative to
  grouping `data`.

## Value

A tibble with one row per group, with the grouping columns and:

- `model`: the model fitted.

- `n`: the number of points fitted.

- `sigma`: the residual standard deviation.

- `fit`: the fitted model, used by
  [`mst_coefs()`](https://bradyajohnston.github.io/tidymst/reference/mst_coefs.md),
  [`mst_curve()`](https://bradyajohnston.github.io/tidymst/reference/mst_curve.md)
  and
  [`mst_normalise()`](https://bradyajohnston.github.io/tidymst/reference/mst_normalise.md).
  `NULL` if the fit failed.

## Models

The **Kd** model describes 1:1 binding of a ligand to a target,
accounting for depletion of free ligand:

\$\$f = \frac{c + c_T + K_d - \sqrt{(c + c_T + K_d)^2 - 4 c c_T}}{2
c_T}\$\$

\$\$y = U + (B - U) f\$\$

where \\c\\ is the ligand concentration, \\c_T\\ the target
concentration, \\f\\ the fraction of target bound, and \\U\\ and \\B\\
the responses of the unbound and bound states.

The **Hill** model describes cooperative binding:

\$\$y = U + \frac{B - U}{1 + (EC\_{50} / c)^n}\$\$

## Examples

``` r
doses <- read_mst_dose_response(
  tidymst_example("dppr10-cy5_dose-response-flat.xlsx")
)
fits <- mst_fit(doses, .by = target)
fits
#> # A tibble: 1 × 5
#>   target  model     n sigma fit       
#>   <chr>   <chr> <int> <dbl> <list>    
#> 1 atpH-fl kd       48  11.0 <mst_bnd_>

mst_coefs(fits)
#> # A tibble: 4 × 7
#>   target  model term                 estimate     std_error conf_low conf_high
#>   <chr>   <chr> <chr>                   <dbl>         <dbl>    <dbl>     <dbl>
#> 1 atpH-fl kd    unbound               1.09e+3 2.44           1.09e+3   1.10e+3
#> 2 atpH-fl kd    bound                 8.51e+2 3.98           8.43e+2   8.59e+2
#> 3 atpH-fl kd    kd                    1.47e-8 0.00000000557  3.51e-9   2.60e-8
#> 4 atpH-fl kd    target_concentration  1.13e-7 0.0000000138   8.54e-8   1.41e-7

# Fix the target concentration at its nominal value
mst_fit(doses, target_concentration = 50e-9, .by = target)
#> # A tibble: 1 × 5
#>   target  model     n sigma fit       
#>   <chr>   <chr> <int> <dbl> <list>    
#> 1 atpH-fl kd       48  12.3 <mst_bnd_>
```
