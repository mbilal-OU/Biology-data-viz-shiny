#' Build the Shiny user interface
#' @export
app_ui <- function() {
  assets <- system.file("app/www", package = "biovizshiny")
  if (!nzchar(assets) && dir.exists("inst/app/www")) assets <- "inst/app/www"
  if (nzchar(assets)) shiny::addResourcePath("bioviz-assets", assets)
  theme <- bslib::bs_theme(version = 5, primary = "#256D85", secondary = "#D95F59", bg = "#F8FAFC", fg = "#172033")
  bslib::page_navbar(
    title = shiny::tagList(shiny::icon("microscope"), "BioViz Shiny Lab"),
    theme = theme, fillable = TRUE,
    header = shiny::tags$head(shiny::tags$link(rel = "stylesheet", type = "text/css", href = "bioviz-assets/styles.css")),
    bslib::nav_panel("Overview", overview_ui("overview"), icon = shiny::icon("house")),
    bslib::nav_panel("Differential expression", de_ui("de"), icon = shiny::icon("chart-line")),
    bslib::nav_panel("Longitudinal", timecourse_ui("timecourse"), icon = shiny::icon("wave-square")),
    bslib::nav_panel("Microbiome", microbiome_ui("microbiome"), icon = shiny::icon("bacteria")),
    bslib::nav_panel("Pathways", pathway_ui("pathways"), icon = shiny::icon("circle-nodes")),
    bslib::nav_panel("Sequencing QC", qc_ui("qc"), icon = shiny::icon("check-double")),
    bslib::nav_spacer(),
    bslib::nav_item(shiny::tags$a("Source", href = "https://github.com/mbilal-OU/shiny-omics-explorer", target = "_blank"))
  )
}

#' Build the Shiny server
#' @export
app_server <- function(input, output, session) {
  datasets <- shiny::reactiveVal(load_app_data())
  overview_server("overview", datasets)
  de_server("de", shiny::reactive(datasets()$differential_expression))
  timecourse_server("timecourse", shiny::reactive(datasets()$timecourse))
  microbiome_server("microbiome", shiny::reactive(datasets()$microbiome))
  pathway_server("pathways", shiny::reactive(datasets()$pathways))
  qc_server("qc", shiny::reactive(datasets()$sequencing_qc))
}

#' Run the biological visualization application
#' @param ... Arguments passed to `shiny::runApp()`.
#' @export
run_app <- function(...) {
  app <- shiny::shinyApp(ui = app_ui(), server = app_server)
  shiny::runApp(app, ...)
}
