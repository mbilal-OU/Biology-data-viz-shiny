test_that("bundled data satisfy every application contract", {
  data <- load_app_data()
  expect_named(data, c("differential_expression", "expression", "timecourse", "microbiome", "sequencing_qc", "pathways"))
  expect_true(all(vapply(data, is.data.frame, logical(1))))
})

test_that("missing files and columns fail before rendering", {
  empty <- tempfile(); dir.create(empty)
  expect_error(load_app_data(empty), "files are missing")
  bad <- data.frame(gene = "A")
  expect_error(biovizshiny:::validate_frame(bad, c("gene", "value"), "test"), "missing columns")
})

test_that("application UI is an HTML tag tree", {
  expect_s3_class(app_ui(), "bslib_page")
})
