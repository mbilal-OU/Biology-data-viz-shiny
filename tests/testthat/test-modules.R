test_that("differential-expression filtering is reactive", {
  d <- data.frame(gene = c("A", "B", "C"), log2_fold_change = c(2, .2, -1.5), adjusted_p_value = c(.01, .001, .08))
  shiny::testServer(biovizshiny:::de_server, args = list(data = shiny::reactive(d)), {
    session$setInputs(fdr = .05, effect = 1)
    expect_equal(filtered()$gene, "A")
    session$setInputs(effect = .1)
    expect_equal(filtered()$gene, c("A", "B"))
  })
})

test_that("longitudinal module preserves selected conditions", {
  d <- data.frame(subject = c("S1", "S1", "S2", "S2"), treatment = rep(c("Control", "Treatment"), each = 2), time = c(0, 1, 0, 1), response = 1:4)
  shiny::testServer(biovizshiny:::timecourse_server, args = list(data = shiny::reactive(d)), {
    session$setInputs(treatment = "Treatment", subjects = TRUE)
    expect_true(all(selected()$treatment == "Treatment"))
  })
})

test_that("microbiome module normalizes within sample", {
  d <- data.frame(sample = rep(c("S1", "S2"), each = 3), group = rep(c("Healthy", "Disease"), each = 3), taxon = rep(c("A", "B", "C"), 2), count = c(2, 3, 5, 1, 1, 2))
  shiny::testServer(biovizshiny:::microbiome_server, args = list(data = shiny::reactive(d)), {
    session$setInputs(groups = c("Healthy", "Disease"), taxa = 3)
    totals <- dplyr::summarise(dplyr::group_by(composition(), sample), total = sum(relative_abundance), .groups = "drop")
    expect_equal(totals$total, c(1, 1))
  })
})

test_that("pathway and QC thresholds update their reactive subsets", {
  pathways <- data.frame(pathway = c("A", "B"), category = c("Immune signaling", "Metabolism"), gene_ratio = c(.2, .3), adjusted_p_value = c(.01, .08), hits = c(5, 7))
  shiny::testServer(biovizshiny:::pathway_server, args = list(data = shiny::reactive(pathways)), {
    session$setInputs(fdr = .05, categories = c("Immune signaling", "Metabolism"))
    expect_equal(selected()$pathway, "A")
  })
  qc <- data.frame(sample = c("S1", "S2"), batch = c("B1", "B2"), reads_million = c(20, 30), mapping_rate = c(.88, .95), q30_rate = c(.92, .87), duplication_rate = c(.2, .3))
  shiny::testServer(biovizshiny:::qc_server, args = list(data = shiny::reactive(qc)), {
    session$setInputs(mapping = .9, q30 = .9)
    expect_equal(assessed()$review, c(TRUE, TRUE))
  })
})

