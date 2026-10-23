# An MO.Control project, made by removing the analysis from the example
# MO.Affinity Analysis project.
local_control_project <- function(env = parent.frame()) {
  path <- withr::local_tempfile(fileext = ".moc", .local_envir = env)
  file.copy(tidymst_example("dppr10-cy5.nta"), path)
  con <- DBI::dbConnect(RSQLite::SQLite(), path)
  on.exit(DBI::dbDisconnect(con))
  tables <- DBI::dbListTables(con)
  analysis <- tables[
    startsWith(tables, "AffinityAnalysis") | tables == "FitParameter"
  ]
  for (table in analysis) {
    DBI::dbRemoveTable(con, table)
  }
  path
}

# A project with no measurements, as MO.Control saves a new project.
local_empty_project <- function(env = parent.frame()) {
  path <- withr::local_tempfile(fileext = ".moc", .local_envir = env)
  con <- DBI::dbConnect(RSQLite::SQLite(), path)
  on.exit(DBI::dbDisconnect(con))
  DBI::dbWriteTable(
    con,
    "Project",
    data.frame(
      Caption = "Empty",
      CreatedOn = "2020-01-01 00:00:00Z",
      UpdatedOn = "2020-01-01 00:00:00Z"
    )
  )
  path
}
