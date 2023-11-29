source("helper-common.R")

expect_snapshot_eafplot <- function(file, ...)
  expect_snapshot_plot(file, eafplot(...))

test_that("eafplot", {
  skip_on_cran()
## FIXME: Add main=invokation
  ## FIXME: We need smaller data!
  eaftest <- function(a, b, maximise = FALSE) {
    A1 <- read_extdata(a)
    A2 <- read_extdata(b)
    if (any(maximise)) {
      A1[, which(maximise)] <- -A1[, which(maximise)]
      A2[, which(maximise)] <- -A2[, which(maximise)]
    }
    # FIXME: Colors are wrong
    expect_snapshot_eafplot(paste0(a, "-area-", maximise2str(maximise)),
      A1, type = "area", legend.pos = "bottomleft", maximise = maximise)
    expect_snapshot_eafplot(paste0(a, "-point-", maximise2str(maximise)),
      A1, type = "point", maximise = maximise)
    expect_snapshot_eafplot(paste0(a, "-", b, "-area-", maximise2str(maximise)),
      list(A1 = A1, A2 = A2), type = "area", legend.pos = "bottomleft", maximise = maximise)
    expect_snapshot_eafplot(paste0(a, "-", b, "-point-", maximise2str(maximise)),
      list(A1 = A1, A2 = A2), type = "point", maximise = maximise)
    expect_snapshot_eafplot(paste0(a, "-", b, "-point-pch20", maximise2str(maximise)),
      list(A1 = A1, A2 = A2), type = "point", pch = 20, maximise = maximise)
}

eaftest("wrots_l10w100_dat", "wrots_l100w10_dat")
eaftest("tpls", "rest")
eaftest("ALG_1_dat.xz", "ALG_2_dat.xz")
eaftest("ALG_1_dat.xz", "ALG_2_dat.xz", maximise = c(TRUE, FALSE))
eaftest("ALG_1_dat.xz", "ALG_2_dat.xz", maximise = c(FALSE, TRUE))
eaftest("ALG_1_dat.xz", "ALG_2_dat.xz", maximise = c(TRUE, TRUE))
})

data(HybridGA, package="moocore")

test_that("eafplot SPEA2relativeVanzyl", {
  skip_on_cran()
  data(SPEA2relativeVanzyl, package="moocore")
  expect_snapshot_eafplot("SPEA2relativeVanzyl",
    SPEA2relativeVanzyl, percentiles = c(25, 50, 75),
            xlab = expression(C[E]), ylab = "Total switches", xlim = c(320, 400))

  expect_snapshot_eafplot("SPEA2relativeVanzyl-extra_points",
    SPEA2relativeVanzyl, percentiles = c(25, 50, 75), xlab = expression(C[E]),
            ylab = "Total switches", xlim = c(320, 400), extra.points = HybridGA$vanzyl,
            extra.legend = "Hybrid GA")
})

test_that("eafplot SPEA2relativeRichmond", {
  skip_on_cran()
  data(SPEA2relativeRichmond, package="moocore")
  expect_snapshot_eafplot("SPEA2relativeRichmond",
    SPEA2relativeRichmond, percentiles = c(25, 50, 75),
    xlab = expression(C[E]), ylab = "Total switches",
    xlim = c(90, 140), ylim = c(0, 25))
  expect_snapshot_eafplot("SPEA2relativeRichmond-extra_points",
    SPEA2relativeRichmond, percentiles = c(25, 50, 75), xlab = expression(C[E]),
            ylab = "Total switches", xlim = c(90, 140), ylim = c(0, 25), extra.points = HybridGA$richmond,
            extra.lty = "dashed", extra.legend = "Hybrid GA")
})

test_that("eafplot SPEA2minstoptimeRichmond", {
  skip_on_cran()
  data(SPEA2minstoptimeRichmond, package="moocore")
  SPEA2minstoptimeRichmond[,2] <- SPEA2minstoptimeRichmond[,2] / 60
  expect_snapshot_eafplot("SPEA2minstoptimeRichmond",
    SPEA2minstoptimeRichmond, xlab = expression(C[E]),
    ylab = "Minimum idle time (minutes)",
    las = 1, log = "y", maximise = c(FALSE, TRUE), main = "SPEA2 (Richmond)",
    legend.pos = "bottomright")
})
