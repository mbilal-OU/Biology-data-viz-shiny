required_schemas <- list(
  differential_expression = c("gene", "log2_fold_change", "adjusted_p_value"),
  expression = c("gene", "condition", "sample", "expression"),
  timecourse = c("subject", "treatment", "time", "response"),
  microbiome = c("sample", "group", "taxon", "count"),
  sequencing_qc = c("sample", "batch", "reads_million", "mapping_rate", "q30_rate", "duplication_rate"),
  pathways = c("pathway", "category", "gene_ratio", "adjusted_p_value", "hits")
)

validate_frame <- function(data, required, name) {
  if (!is.data.frame(data)) stop(name, " must be a data frame.", call. = FALSE)
  missing <- setdiff(required, names(data))
  if (length(missing)) stop(name, " is missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  invisible(data)
}

#' Load and validate application teaching data
#' @param data_dir Directory containing the six CSV files. When `NULL`, uses
#'   repository `data/` during development and installed app data otherwise.
#' @return A named list of validated data frames.
#' @export
load_app_data <- function(data_dir = NULL) {
  if (is.null(data_dir)) {
    data_dir <- if (dir.exists("data")) "data" else system.file("app/data", package = "biovizshiny")
  }
  if (!nzchar(data_dir) || !dir.exists(data_dir)) stop("Application data directory was not found.", call. = FALSE)
  files <- c(
    differential_expression = "differential_expression.csv",
    expression = "expression.csv", timecourse = "timecourse.csv",
    microbiome = "microbiome.csv", sequencing_qc = "sequencing_qc.csv",
    pathways = "pathways.csv"
  )
  missing_files <- files[!file.exists(file.path(data_dir, files))]
  if (length(missing_files)) stop("Application data files are missing: ", paste(missing_files, collapse = ", "), call. = FALSE)
  result <- lapply(files, function(file) utils::read.csv(file.path(data_dir, file), check.names = FALSE))
  for (name in names(result)) validate_frame(result[[name]], required_schemas[[name]], name)
  result
}
