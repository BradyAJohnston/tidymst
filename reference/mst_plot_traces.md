# Plot MST traces

Draws one line per capillary. Requires ggplot2.

## Usage

``` r
mst_plot_traces(data, colour = ligand_concentration)
```

## Arguments

- data:

  A data frame of traces, as returned by
  [`read_mst_traces()`](https://bradyajohnston.github.io/tidymst/reference/read_mst_traces.md).

- colour:

  \<[`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html)\>
  The column to colour lines by. Numeric columns are coloured on a log
  scale.

## Value

A ggplot.

## Examples

``` r
traces <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
mst_plot_traces(traces)
```
