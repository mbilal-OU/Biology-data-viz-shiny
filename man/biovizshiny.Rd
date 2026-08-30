\name{biovizshiny}
\alias{app_ui}
\alias{app_server}
\alias{load_app_data}
\alias{run_app}
\title{Run the modular biological visualization Shiny application}
\description{Build, validate, and run a modular application for interactive differential expression, longitudinal, microbiome, pathway, and sequencing-QC exploration.}
\usage{
app_ui()
app_server(input, output, session)
load_app_data(data_dir = NULL)
run_app(...)
}
\arguments{
\item{input, output, session}{Standard Shiny server objects.}
\item{data_dir}{Directory containing the six documented CSV files.}
\item{...}{Arguments passed to \code{shiny::runApp()}.}
}
\value{UI/server objects, a named list of data frames, or a running Shiny application.}

