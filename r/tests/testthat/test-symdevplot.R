test_that("symdevplot", {
  skip_on_cran()
  data(CPFs, package="moocore")
  res <- vorob_t(CPFs, reference = c(2, 200))
  VD <- vorob_dev(CPFs, ve = res$ve, reference = c(2, 200))
  expect_snapshot_plot("symdevplot-CPFs-nlevels11", {
    symdevplot(CPFs, ve = res$ve, threshold = res$threshold, nlevels = 11)
  })
  expect_snapshot_plot("symdevplot-CPFs-nlevels200", {
    symdevplot(CPFs, ve = res$ve, threshold = res$threshold, nlevels = 200, legend.pos = "none")
  })
  expect_snapshot_plot("symdevplot-CPFs-heatcolors", {
    symdevplot(CPFs, ve = res$ve, threshold = res$threshold, nlevels = 11, col.fun = heat.colors)
  })
})
