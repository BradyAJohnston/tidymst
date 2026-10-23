# Get paths to example exports

tidymst comes bundled with example MO.Affinity Analysis exports in its
`inst/extdata` directory. This function makes them easy to access.

## Usage

``` r
tidymst_example(file = NULL)
```

## Arguments

- file:

  Name of a file. If `NULL`, the example files will be listed.

## Value

A path, or a character vector of file names.

## Details

Most of the files are from one experiment: the binding of a Cy5-labelled
PPR protein, dPPR10-Cy5, to two RNA targets (atpH-fl and NEAT1-fl),
exported in several formats.

## Examples

``` r
tidymst_example()
#> [1] "dppr10-cy5_compare-fnorm.xlsx"         
#> [2] "dppr10-cy5_compare-fraction-bound.xlsx"
#> [3] "dppr10-cy5_dose-response-flat.xlsx"    
#> [4] "dppr10-cy5_dose-response-grouped.xlsx" 
#> [5] "dppr10-cy5_traces.xlsx"                
#> [6] "dppr10c2_capillary-scan.xlsx"          
#> [7] "dsnppr10_compare-delta-fnorm.xlsx"     
#> [8] "dsnppr10_compare-grid.xlsx"            
tidymst_example("dppr10-cy5_traces.xlsx")
#> [1] "/home/runner/work/_temp/Library/tidymst/extdata/dppr10-cy5_traces.xlsx"
```
