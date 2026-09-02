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
  readme <- paste(readLines("README.md", warn = FALSE), collapse = "\n")
  guide <- paste(readLines("docs/figure-tutorials.md", warn = FALSE), collapse = "\n")

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
