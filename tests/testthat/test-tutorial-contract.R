figures <- c(
  "01_overview.png",
  "02_differential_expression.png",
  "03_longitudinal.png",
  "04_microbiome.png",
  "05_pathways.png",
  "06_sequencing_qc.png",
  "application_architecture.svg"
)

test_that("every documented app figure links to a complete tutorial", {
  root <- Sys.getenv("GITHUB_WORKSPACE", unset = getwd())
  readme_path <- file.path(root, "README.md")
  guide_path <- file.path(root, "docs", "figure-tutorials.md")
  skip_if_not(file.exists(readme_path) && file.exists(guide_path), "source documentation is unavailable")
  readme <- paste(readLines(readme_path, warn = FALSE), collapse = "\n")
  guide <- paste(readLines(guide_path, warn = FALSE), collapse = "\n")

  for (figure in figures) {
    expect_true(grepl(
      paste0("figures/", figure, ")\\]\\(docs/figure-tutorials.md#"),
      readme
    ))
  }

  expect_equal(length(gregexpr("\\*\\*Use when:\\*\\*", guide)[[1]]), length(figures))
  expect_equal(length(gregexpr("\\*\\*Data and code:\\*\\*", guide)[[1]]), length(figures))
  expect_equal(length(gregexpr("\\*\\*Use your own data:\\*\\*", guide)[[1]]), length(figures))
  expect_equal(length(gregexpr("\\*\\*Interpret:\\*\\*", guide)[[1]]), length(figures))
})
