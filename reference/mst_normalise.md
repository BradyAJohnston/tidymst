# Normalise responses to delta Fnorm and fraction bound

Uses the unbound and bound states of fitted models to express responses
relative to the unbound state (delta Fnorm), and as the fraction of
target bound. This puts merge sets with different baselines on the same
scale.

## Usage

``` r
mst_normalise(data, fits, response = response)
```

## Arguments

- data:

  A data frame of dose-response data, as passed to
  [`mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/mst_fit.md).

- fits:

  A tibble of fits from
  [`mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/mst_fit.md).
  Its grouping columns must also be in `data`.

- response:

  \<[`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  The column of response, in the same units as the fits.

## Value

`data` with two new columns:

- `delta_fnorm`: the response minus the unbound response.

- `fraction_bound`: `delta_fnorm` divided by the difference between the
  bound and unbound responses.

## Examples

``` r
doses <- read_mst_dose_response(
  tidymst_example("dppr10-cy5_dose-response-flat.xlsx")
)
fits <- mst_fit(doses, .by = target)
mst_normalise(doses, fits)
#> # A tibble: 48 × 27
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
#> # ℹ 21 more variables: ligand_concentration <dbl>, response_type <chr>,
#> #   response <dbl>, project <chr>, analysis_set <chr>, analysis_type <chr>,
#> #   evaluation_strategy <chr>, origin <chr>, measured_at <dttm>,
#> #   cold_start <dbl>, cold_end <dbl>, hot_start <dbl>, hot_end <dbl>,
#> #   mst_power <chr>, excitation_power <dbl>, temperature <dbl>,
#> #   exported_on <dttm>, bleaching_rate <dbl>, initial_fluorescence <dbl>, …
```
