module_card <- function(title, ...) bslib::card(bslib::card_header(title), ...)

overview_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    bslib::layout_columns(
      bslib::value_box("Genes", shiny::textOutput(ns("genes")), showcase = shiny::icon("dna"), theme = "primary"),
      bslib::value_box("Samples", shiny::textOutput(ns("samples")), showcase = shiny::icon("vials"), theme = "success"),
      bslib::value_box("Sequencing libraries", shiny::textOutput(ns("libraries")), showcase = shiny::icon("chart-line"), theme = "warning")
    ),
    bslib::layout_columns(
      module_card("Analysis coverage", plotly::plotlyOutput(ns("coverage"), height = "360px")),
      module_card("Scientific contract", shiny::uiOutput(ns("contract"))),
      col_widths = c(7, 5)
    )
  )
}

overview_server <- function(id, data) shiny::moduleServer(id, function(input, output, session) {
  output$genes <- shiny::renderText(length(unique(data()$differential_expression$gene)))
  output$samples <- shiny::renderText(length(unique(data()$expression$sample)))
  output$libraries <- shiny::renderText(nrow(data()$sequencing_qc))
  output$coverage <- plotly::renderPlotly({
    counts <- data.frame(
      analysis = c("Differential expression", "Longitudinal", "Microbiome", "Pathways", "Sequencing QC"),
      records = c(nrow(data()$differential_expression), nrow(data()$timecourse), nrow(data()$microbiome), nrow(data()$pathways), nrow(data()$sequencing_qc))
    )
    plotly::plot_ly(counts, x = ~records, y = ~stats::reorder(analysis, records), type = "bar", orientation = "h", marker = list(color = "#256D85"), hovertemplate = "%{y}: %{x:,} records<extra></extra>") |>
      plotly::layout(xaxis = list(title = "Records"), yaxis = list(title = ""), margin = list(l = 140))
  })
  output$contract <- shiny::renderUI(shiny::tags$ul(
    shiny::tags$li("All bundled data are deterministic simulations."),
    shiny::tags$li("Filters change exploration, not confirmatory inference."),
    shiny::tags$li("Downloads include the current reactive subset."),
    shiny::tags$li("Validation fails before a misleading plot is rendered.")
  ))
})

de_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      shiny::sliderInput(ns("fdr"), "Adjusted p-value", min = 0.001, max = 0.1, value = 0.05, step = 0.001),
      shiny::sliderInput(ns("effect"), "Absolute log2 fold change", min = 0.25, max = 2.5, value = 1, step = 0.25),
      shiny::downloadButton(ns("download"), "Download filtered genes")
    ),
    module_card("Interactive volcano plot", plotly::plotlyOutput(ns("plot"), height = "520px")),
    module_card("Filtered result table", DT::DTOutput(ns("table")))
  )
}

de_server <- function(id, data) shiny::moduleServer(id, function(input, output, session) {
  filtered <- shiny::reactive({
    shiny::req(input$fdr, input$effect)
    dplyr::filter(data(), adjusted_p_value <= input$fdr, abs(log2_fold_change) >= input$effect)
  })
  output$plot <- plotly::renderPlotly({
    d <- dplyr::mutate(data(), result = ifelse(adjusted_p_value <= input$fdr & abs(log2_fold_change) >= input$effect, ifelse(log2_fold_change > 0, "Up", "Down"), "Not significant"))
    plotly::plot_ly(d, x = ~log2_fold_change, y = ~-log10(adjusted_p_value), text = ~gene, color = ~result,
      colors = c("Down" = "#3B82A0", "Not significant" = "#CBD5E1", "Up" = "#D95F59"), type = "scatter", mode = "markers",
      marker = list(size = 7, opacity = 0.72), hovertemplate = "%{text}<br>log2FC %{x:.2f}<br>-log10 FDR %{y:.2f}<extra></extra>") |>
      plotly::layout(xaxis = list(title = "log2 fold change"), yaxis = list(title = "-log10 adjusted p-value"), legend = list(orientation = "h"))
  })
  output$table <- DT::renderDT(DT::datatable(filtered(), rownames = FALSE, options = list(pageLength = 8, scrollX = TRUE)))
  output$download <- shiny::downloadHandler(filename = function() "filtered_differential_expression.csv", content = function(file) utils::write.csv(filtered(), file, row.names = FALSE))
  list(filtered = filtered)
})

timecourse_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(shiny::checkboxGroupInput(ns("treatment"), "Conditions", choices = c("Control", "Treatment"), selected = c("Control", "Treatment")), shiny::checkboxInput(ns("subjects"), "Show subject trajectories", TRUE)),
    module_card("Subject-aware response", plotly::plotlyOutput(ns("plot"), height = "560px"))
  )
}

timecourse_server <- function(id, data) shiny::moduleServer(id, function(input, output, session) {
  selected <- shiny::reactive({ shiny::req(input$treatment); dplyr::filter(data(), treatment %in% input$treatment) })
  output$plot <- plotly::renderPlotly({
    d <- selected(); means <- dplyr::summarise(dplyr::group_by(d, treatment, time), response = mean(response), .groups = "drop")
    p <- ggplot2::ggplot(d, ggplot2::aes(time, response, colour = treatment))
    if (isTRUE(input$subjects)) p <- p + ggplot2::geom_line(ggplot2::aes(group = interaction(subject, treatment)), alpha = 0.16)
    p <- p + ggplot2::geom_line(data = means, ggplot2::aes(group = treatment), linewidth = 1.2) + ggplot2::geom_point(data = means, size = 2.5) + ggplot2::scale_colour_manual(values = c(Control = "#3B82A0", Treatment = "#D95F59")) + ggplot2::theme_minimal() + ggplot2::labs(x = "Time (hours)", y = "Response", colour = "Condition")
    plotly::ggplotly(p, tooltip = c("time", "response", "treatment"))
  })
  list(selected = selected)
})

microbiome_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(shiny::checkboxGroupInput(ns("groups"), "Cohorts", choices = c("Healthy", "Disease"), selected = c("Healthy", "Disease")), shiny::sliderInput(ns("taxa"), "Top taxa", 3, 6, 6, 1)),
    module_card("Relative community composition", plotly::plotlyOutput(ns("plot"), height = "560px"))
  )
}

microbiome_server <- function(id, data) shiny::moduleServer(id, function(input, output, session) {
  composition <- shiny::reactive({
    shiny::req(input$groups, input$taxa)
    d <- dplyr::filter(data(), group %in% input$groups)
    totals <- dplyr::summarise(dplyr::group_by(d, taxon), total = sum(count), .groups = "drop") |> dplyr::arrange(dplyr::desc(total))
    keep <- utils::head(totals$taxon, input$taxa)
    d |> dplyr::mutate(taxon = ifelse(taxon %in% keep, taxon, "Other")) |> dplyr::group_by(sample, group, taxon) |> dplyr::summarise(count = sum(count), .groups = "drop") |> dplyr::group_by(sample) |> dplyr::mutate(relative_abundance = count / sum(count)) |> dplyr::ungroup()
  })
  output$plot <- plotly::renderPlotly({
    p <- ggplot2::ggplot(composition(), ggplot2::aes(sample, relative_abundance, fill = taxon, text = paste0(taxon, ": ", scales::percent(relative_abundance, accuracy = 0.1)))) + ggplot2::geom_col() + ggplot2::facet_grid(~group, scales = "free_x", space = "free_x") + ggplot2::scale_y_continuous(labels = scales::label_percent()) + ggplot2::scale_fill_viridis_d(option = "C") + ggplot2::theme_minimal() + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 60, hjust = 1)) + ggplot2::labs(x = "Sample", y = "Relative abundance", fill = "Taxon")
    plotly::ggplotly(p, tooltip = "text")
  })
  list(composition = composition)
})

pathway_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      shiny::sliderInput(ns("fdr"), "Maximum adjusted p-value", 0.001, 0.1, 0.05, 0.001),
      shiny::checkboxGroupInput(ns("categories"), "Categories", choices = c("Immune signaling", "Metabolism", "Cellular stress"), selected = c("Immune signaling", "Metabolism", "Cellular stress"))
    ),
    module_card("Enrichment evidence", plotly::plotlyOutput(ns("plot"), height = "520px")),
    module_card("Selected pathways", DT::DTOutput(ns("table")))
  )
}

pathway_server <- function(id, data) shiny::moduleServer(id, function(input, output, session) {
  selected <- shiny::reactive({ shiny::req(input$fdr, input$categories); dplyr::filter(data(), adjusted_p_value <= input$fdr, category %in% input$categories) })
  output$plot <- plotly::renderPlotly({
    d <- selected()
    shiny::validate(shiny::need(nrow(d) > 0, "No pathways satisfy the current filters."))
    plotly::plot_ly(d, x = ~gene_ratio, y = ~stats::reorder(pathway, gene_ratio), size = ~hits, color = ~-log10(adjusted_p_value), colors = "Viridis", type = "scatter", mode = "markers", text = ~category,
      hovertemplate = "%{y}<br>Gene ratio %{x:.2f}<br>Hits %{marker.size}<extra></extra>") |>
      plotly::layout(xaxis = list(title = "Gene ratio"), yaxis = list(title = ""), margin = list(l = 170))
  })
  output$table <- DT::renderDT(DT::datatable(selected(), rownames = FALSE, options = list(pageLength = 8, scrollX = TRUE)))
  list(selected = selected)
})

qc_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(shiny::sliderInput(ns("mapping"), "Minimum mapping rate", .75, .98, .90, .01), shiny::sliderInput(ns("q30"), "Minimum Q30 rate", .80, .98, .90, .01)),
    module_card("Sequencing QC", plotly::plotlyOutput(ns("plot"), height = "480px")),
    module_card("Libraries requiring review", DT::DTOutput(ns("table")))
  )
}

qc_server <- function(id, data) shiny::moduleServer(id, function(input, output, session) {
  assessed <- shiny::reactive({ shiny::req(input$mapping, input$q30); dplyr::mutate(data(), review = mapping_rate < input$mapping | q30_rate < input$q30) })
  output$plot <- plotly::renderPlotly({
    plotly::plot_ly(assessed(), x = ~reads_million, y = ~mapping_rate, color = ~review, symbol = ~batch, type = "scatter", mode = "markers", text = ~sample, marker = list(size = 10), hovertemplate = "%{text}<br>Reads %{x:.1f}M<br>Mapping %{y:.1%}<extra></extra>") |> plotly::layout(xaxis = list(title = "Reads (million)"), yaxis = list(title = "Mapping rate", tickformat = ".0%"), legend = list(orientation = "h"))
  })
  output$table <- DT::renderDT(DT::datatable(dplyr::filter(assessed(), review), rownames = FALSE, options = list(pageLength = 6, scrollX = TRUE)))
  list(assessed = assessed)
})
