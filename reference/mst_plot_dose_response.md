# Plot dose-response curves

Draws the response at each concentration, with error bars if `data` has
an `error` column, and optionally the fitted curves. Requires ggplot2.

## Usage

``` r
mst_plot_dose_response(
  data,
  fits = NULL,
  concentration = ligand_concentration,
  response = response,
  colour = NULL
)
```

## Arguments

- data:

  A data frame of dose-response data, such as from
  [`read_mst_dose_response()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_dose_response.md)
  or
  [`mst_fnorm()`](https://bradyajohnston.github.io/tidymst/reference/mst_fnorm.md).

- fits:

  Optionally, a tibble of fits from
  [`mst_fit()`](https://bradyajohnston.github.io/tidymst/reference/mst_fit.md)
  to draw.

- concentration, response, colour:

  \<[`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  The columns of ligand concentration, response, and colour of the
  points.

## Value

A ggplot.

## Examples

``` r
doses <- read_mst_dose_response(
  tidymst_example("dppr10-cy5_dose-response-flat.xlsx")
)
fits <- mst_fit(doses, .by = target)
mst_plot_dose_response(doses, fits, colour = target)
```
