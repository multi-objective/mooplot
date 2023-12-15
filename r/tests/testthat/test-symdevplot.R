test_that("symdevplot", {
  skip_on_cran()
  data(CPFs, package="moocore")
  res <- vorobT(CPFs, reference = c(2, 200))
  VD <- vorobDev(CPFs, VE = res$VE, reference = c(2, 200))
  expect_snapshot_plot("symdevplot-CPFs-nlevels11", {
    symdevplot(CPFs, VE = res$VE, threshold = res$threshold, nlevels = 11)
  })
  expect_snapshot_plot("symdevplot-CPFs-nlevels200", {
    symdevplot(CPFs, VE = res$VE, threshold = res$threshold, nlevels = 200, legend.pos = "none")
  })
  expect_snapshot_plot("symdevplot-CPFs-heatcolors", {
    symdevplot(CPFs, VE = res$VE, threshold = res$threshold, nlevels = 11, col.fun = heat.colors)
  })
})
