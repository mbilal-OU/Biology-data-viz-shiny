# Shiny tutorials for reactive omics exploration

These tutorials explain what each application view does, its data and module,
how to replace the bundled simulation, and what users may conclude. Shiny does
not rerun upstream biological inference unless that analysis is explicitly
implemented in a server module.

## 01 Overview and data contracts

- **Use when:** users need scope, record counts, and interpretation limits before
  exploring results.
- **Data and code:** all tables loaded by [`load_app_data()`](../R/data.R) and the
  [`overview_ui()` / `overview_server()`](../R/modules.R) module pair.
- **Use your own data:** replace each CSV with a schema-compatible table in the
  app data directory, or call `load_app_data("path/to/data")`. Validation stops
  startup when required columns are missing.
- **Interpret:** counts describe what is available to the app. They are not
  sample-size justification, quality assessment, or inferential results.

## 02 Differential-expression module

- **Use when:** FDR and effect-size thresholds should update a volcano plot,
  result table, and download together.
- **Data and code:** [`differential_expression.csv`](../data/differential_expression.csv)
  and [`de_ui()` / `de_server()`](../R/modules.R).
- **Use your own data:** provide gene IDs, log2 fold changes, and adjusted
  p-values. Replace the CSV or pass the validated frame to the server module.
- **Interpret:** controls filter supplied results; they do not refit a
  differential-expression model or recalculate multiple-testing correction.

## 03 Longitudinal response module

- **Use when:** condition selection and optional subject lines should update a
  repeated-measures view.
- **Data and code:** [`timecourse.csv`](../data/timecourse.csv) and
  [`timecourse_ui()` / `timecourse_server()`](../R/modules.R).
- **Use your own data:** retain subject, treatment, time, and response in long
  format. Validate that each trajectory belongs to one experimental unit.
- **Interpret:** reactive selection changes what is displayed, not the study
  design. Use an appropriate repeated-measures model for inference.

## 04 Microbiome composition module

- **Use when:** users need to change cohort and top-taxon choices while the plot
  remains normalized within sample.
- **Data and code:** [`microbiome.csv`](../data/microbiome.csv) and
  [`microbiome_ui()` / `microbiome_server()`](../R/modules.R).
- **Use your own data:** provide sample, cohort, taxon, and nonnegative count
  columns. Review the top-taxon aggregation and zero handling for your study.
- **Interpret:** bars are descriptive relative compositions. Filtering and
  normalization do not provide differential-abundance inference.

## 05 Pathway enrichment module

- **Use when:** category and adjusted-evidence controls should synchronize a dot
  plot with the selected pathway table.
- **Data and code:** [`pathways.csv`](../data/pathways.csv) and
  [`pathway_ui()` / `pathway_server()`](../R/modules.R).
- **Use your own data:** supply pathway, category, gene ratio, hit count, and
  adjusted p-value from a documented enrichment workflow.
- **Interpret:** the module filters upstream results. Conclusions depend on the
  tested universe, database version, test, and correction method.

## 06 Sequencing quality-control module

- **Use when:** user-set thresholds should flag the same libraries in both plot
  and table.
- **Data and code:** [`sequencing_qc.csv`](../data/sequencing_qc.csv) and
  [`qc_ui()` / `qc_server()`](../R/modules.R).
- **Use your own data:** provide one row per library with depth, mapping, Q30,
  duplication, batch, and sample fields. Set defensible protocol-specific
  defaults in the UI.
- **Interpret:** a flag means review is required. It is not an automatic reason
  to exclude a library or repeat sequencing.

## Application architecture

- **Use when:** developers need to understand how inputs propagate through
  validated reactive transformations to visible and downloadable outputs.
- **Data and code:** [`app_ui()` / `app_server()`](../R/app.R), shared data loading
  in [`R/data.R`](../R/data.R), and namespaced modules in
  [`R/modules.R`](../R/modules.R).
- **Use your own data:** load once, validate once, pass explicit frames into
  module servers, and keep module state inside its namespace.
- **Interpret:** the diagram is a software data-flow model. It does not represent
  a biological pathway or statistical-analysis pipeline.

## Run and test the app

```r
remotes::install_local(".", dependencies = TRUE)
biovizshiny::run_app(launch.browser = TRUE)
testthat::test_local()
```

Read the [deployment guide](deployment.md) before exposing personal or sensitive
biological data. Keep credentials and protected data outside the repository.
