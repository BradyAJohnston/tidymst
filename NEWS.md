# tidymst (development version)

* Read MO.Control (`.moc`) and MO.Affinity Analysis (`.nta`) project files, which are SQLite databases, with `read_mst()`, `read_mst_traces()`, `read_mst_capillary_scan()`, `read_mst_dose_response()`, `read_mst_fit()` and `read_mst_metadata()`. Projects give raw fluorescence counts and the fits as last saved, with standard errors.
* Read exports from MO.Affinity Analysis with `read_mst()`, `read_mst_traces()`, `read_mst_capillary_scan()`, `read_mst_dose_response()`, `read_mst_fit()`, `read_mst_fit_curve()` and `read_mst_metadata()`. Detect the type of an export with `mst_export_type()`.
* Analyse MST data with `mst_fnorm()`, `mst_fit()`, `mst_coefs()`, `mst_curve()` and `mst_normalise()`.
* Plot MST data with `mst_plot_traces()` and `mst_plot_dose_response()`.
