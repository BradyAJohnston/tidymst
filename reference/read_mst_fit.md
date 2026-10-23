# Read binding fits

Reads the fits that MO.Affinity Analysis made to each merge set. These
are included in Compare Results (Chart and Grid) and Dose-Response
(Grouped) exports.

## Usage

``` r
read_mst_fit(path)
```

## Arguments

- path:

  Path to an `.xlsx` file exported from MO.Affinity Analysis, or a
  `.moc` or `.nta` project file.

## Value

A tibble with one row per merge set, with columns:

- `series`, `merge_set`, `target`, `target_concentration` and `ligand`
  identify the merge set. `series` is missing for Grid exports.

- `model`: the fit model, `"kd"` or `"hill"`.

- `unbound` and `bound`: the response of the unbound and bound states.

- `kd` and `kd_confidence` (Kd model): the dissociation constant and its
  confidence, in molar.

- `target_concentration_fit` (Kd model): the target concentration used
  in the fit, which may differ from the nominal `target_concentration`
  if it was a free parameter.

- `ec50`, `ec50_confidence` and `hill` (Hill model): the half-maximal
  concentration, its confidence, and the Hill coefficient.

- `std_dev`: the standard deviation of the residuals.

Grid exports also include fit statistics such as `std_error`,
`reduced_chi_sq` and `signal_to_noise`. MO.Affinity Analysis project
files (`.nta`) give one row per merge set per model fitted, with
standard errors instead of confidences; see the Project files section of
[`read_mst()`](https://bradyajohnston.github.io/tidymst/reference/read_mst.md).

## Examples

``` r
read_mst_fit(tidymst_example("dppr10-cy5_compare-fnorm.xlsx"))
#> # A tibble: 2 × 12
#>   series merge_set      target target_concentration ligand model   bound unbound
#>    <int> <chr>          <chr>                 <dbl> <chr>  <chr>   <dbl>   <dbl>
#> 1      1 dPPR10-Cy5 Tr… atpH-…           0.00000005 dPPR1… kd    8.52e+2   1093.
#> 2      2 dPPR10-Cy5 Tr… NEAT1…           0.00000005 dPPR1… kd    4.67e-4    971.
#> # ℹ 4 more variables: kd <dbl>, target_concentration_fit <dbl>, std_dev <dbl>,
#> #   kd_confidence <dbl>
read_mst_fit(tidymst_example("dsnppr10_compare-delta-fnorm.xlsx"))
#> # A tibble: 2 × 12
#>   series merge_set  target target_concentration ligand model bound unbound  hill
#>    <int> <chr>      <chr>                 <dbl> <chr>  <chr> <dbl>   <dbl> <dbl>
#> 1      1 dsnPPR10 … RNAat…           0.00000005 dsnPP… hill   841.   1061.  1.35
#> 2      2 dsnPPR10 … RNAKP…           0.00000005 dsnPP… hill   973.    972.  1.8 
#> # ℹ 3 more variables: ec50 <dbl>, std_dev <dbl>, ec50_confidence <dbl>
```
