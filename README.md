# Reactive Omics Explorer with Shiny

[![R-CMD-check](https://github.com/mbilal-OU/shiny-omics-explorer/actions/workflows/ci.yml/badge.svg)](https://github.com/mbilal-OU/shiny-omics-explorer/actions/workflows/ci.yml)
[![App smoke test](https://github.com/mbilal-OU/shiny-omics-explorer/actions/workflows/app-smoke.yml/badge.svg)](https://github.com/mbilal-OU/shiny-omics-explorer/actions/workflows/app-smoke.yml)
[![Docs](https://github.com/mbilal-OU/shiny-omics-explorer/actions/workflows/docs.yml/badge.svg)](https://github.com/mbilal-OU/shiny-omics-explorer/actions/workflows/docs.yml)
[![Shiny](https://img.shields.io/badge/Shiny-1.14%2B-1F77B4)](https://shiny.posit.co/r/)
[![License: MIT](https://img.shields.io/badge/license-MIT-2E7D32)](LICENSE.md)

A **production-minded, modular Shiny portfolio for biological data
exploration**. Its distinctive role is reactive analysis delivery: namespaced
modules keep controls, transformations, plots, tables, and downloads
synchronized, with validated inputs, server-side tests, startup smoke testing,
responsive layout, and container deployment.

The bundled data are deterministic simulations. The application is an
exploration and teaching tool, not clinical software or a confirmatory analysis.

## Interface tour

| Application surface | Application surface |
|---|---|
| [**Overview and data contracts**](docs/figure-tutorials.md#01-overview-and-data-contracts)<br>[![Overview dashboard](figures/01_overview.png)](docs/figure-tutorials.md#01-overview-and-data-contracts)<br>At-a-glance scope, record counts, and interpretation boundaries. | [**Differential expression**](docs/figure-tutorials.md#02-differential-expression-module)<br>[![Differential expression module](figures/02_differential_expression.png)](docs/figure-tutorials.md#02-differential-expression-module)<br>Reactive FDR/effect thresholds, hover identifiers, table, and download. |
| [**Longitudinal response**](docs/figure-tutorials.md#03-longitudinal-response-module)<br>[![Longitudinal module](figures/03_longitudinal.png)](docs/figure-tutorials.md#03-longitudinal-response-module)<br>Condition selection and optional subject trajectories preserve study design. | [**Microbiome composition**](docs/figure-tutorials.md#04-microbiome-composition-module)<br>[![Microbiome module](figures/04_microbiome.png)](docs/figure-tutorials.md#04-microbiome-composition-module)<br>Reactive cohort and top-taxon controls with within-sample normalization. |
| [**Pathway enrichment**](docs/figure-tutorials.md#05-pathway-enrichment-module)<br>[![Pathway module](figures/05_pathways.png)](docs/figure-tutorials.md#05-pathway-enrichment-module)<br>Category and adjusted-evidence filters update plot and table together. | [**Sequencing quality control**](docs/figure-tutorials.md#06-sequencing-quality-control-module)<br>[![QC module](figures/06_sequencing_qc.png)](docs/figure-tutorials.md#06-sequencing-quality-control-module)<br>User-set QC thresholds flag libraries consistently across plot and table. |

## Architecture

[![Reactive application architecture](figures/application_architecture.svg)](docs/figure-tutorials.md#application-architecture)

Each module owns its input namespace, reactive transformation, output renderers,
and tests. Shared data loading validates schemas once; modules enforce
analysis-specific state without using global mutable variables.

## Run locally

```r
install.packages(c("remotes", "shiny"))
remotes::install_github("mbilal-OU/shiny-omics-explorer")
biovizshiny::run_app(launch.browser = TRUE)
```

For repository development:

```bash
git clone https://github.com/mbilal-OU/shiny-omics-explorer.git
cd shiny-omics-explorer
Rscript -e 'install.packages("pak"); pak::local_install_dev_deps()'
Rscript -e 'testthat::test_local()'
Rscript -e 'biovizshiny::run_app(host="0.0.0.0", port=3838)'
```

## What this repository proves

| Skill | Evidence |
|---|---|
| Reactive programming | Thresholds, cohorts, taxa, conditions, plots, tables, and downloads stay synchronized |
| Modular architecture | Six namespaced UI/server modules with explicit reactive inputs and returns |
| Interactive visualization | Plotly hover, linked reactive state, ggplot2 grammar, and responsive sizing |
| Biological analysis | Differential expression, repeated measures, composition, enrichment, and sequencing QC |
| Testability | `shiny::testServer()`, data-contract tests, R CMD check, coverage, and HTTP startup smoke test |
| Deployment | Local package, Docker image, Shiny Server layout, and platform deployment guidance |
| Scientific safety | Simulated-data labeling, transformation notes, protocol-specific QC, no clinical claims |

## Test and verify

```bash
Rscript -e 'testthat::test_local()'
R CMD build .
R CMD check --no-manual biovizshiny_1.0.0.tar.gz
docker build -t bioviz-shiny .
docker run --rm -p 3838:3838 bioviz-shiny
```

## Deployment choices

- **shinyapps.io** for a shareable hosted demonstration.
- **Posit Connect** for authentication, scaling, scheduled content, and organizational deployment.
- **Shiny Server / Docker** for self-managed infrastructure; the included container runs as an unprivileged application process behind Shiny Server.

Never put credentials in R source or the repository. Supply secrets through the
deployment platform, apply authentication upstream, limit uploads and memory,
and log errors without logging sensitive biological data.

## Scientific guardrails

- Reactive filtering is exploratory and does not rerun upstream statistical models.
- Subject trajectories preserve repeated-measure identity.
- Relative-abundance composition does not replace compositional inference.
- Pathway views assume a defined tested universe and adjusted p-values.
- QC thresholds are protocol-specific and support review rather than automatic acceptance.
- Downloaded subsets include current filters but not a claim of statistical significance beyond the supplied results.

## Portfolio series

- [Seaborn](https://github.com/mbilal-OU/seaborn-biological-statistics) · [Matplotlib](https://github.com/mbilal-OU/matplotlib-genomic-figures) · [Plotly](https://github.com/mbilal-OU/plotly-interactive-omics)
- [ggplot2](https://github.com/mbilal-OU/ggplot2-omics-grammar) · [ggtree + ComplexHeatmap](https://github.com/mbilal-OU/ggtree-complexheatmap-phylogenomics) · **Shiny** · [Gnuplot](https://github.com/mbilal-OU/gnuplot-bioinformatics-cli)

Citation metadata are in [`CITATION.cff`](CITATION.cff). Code is under the [MIT License](LICENSE.md).
