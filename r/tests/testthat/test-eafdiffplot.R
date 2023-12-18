source("helper-common.R")

expect_snapshot_eafdiffplot <- function(file, ...)
  expect_snapshot_plot(file, scale = c(2,1), eafdiffplot(...))

test_that("eafdiffplot", {
  skip_on_cran()
## FIXME: Add main=invokation
## FIXME: We need smaller data!
eaftest <- function(a, b, maximise = c(FALSE, FALSE)) {
  A1 <- read_extdata(a)
  A2 <- read_extdata(b)
  if (any(maximise)) {
    A1[, which(maximise)] <- -A1[, which(maximise)]
    A2[, which(maximise)] <- -A2[, which(maximise)]
  }
  title_left <- canonical_name(a)
  title_right <- canonical_name(b)
  expect_snapshot_eafdiffplot(paste0(a, "-", b, "-area-", maximise2str(maximise)),
    A1, A2, type = "area", maximise = maximise)
  expect_snapshot_eafdiffplot(paste0(a, "-", b, "-point-", maximise2str(maximise)),
    A1, A2, type = "point", maximise = maximise, title_left = title_left, title_right = title_right)
  expect_snapshot_eafdiffplot(paste0(a, "-", b, "-full-", maximise2str(maximise)),
    A1, A2, full.eaf = TRUE, maximise = maximise, title_left = title_left, title_right = title_right)
}

eaftest("wrots_l10w100_dat", "wrots_l100w10_dat")
eaftest("tpls", "rest")
eaftest("ALG_1_dat.xz", "ALG_2_dat.xz")
eaftest("wrots_l10w100_dat", "wrots_l100w10_dat")
eaftest("wrots_l10w100_dat", "wrots_l100w10_dat", maximise = c(TRUE, FALSE))
eaftest("wrots_l10w100_dat", "wrots_l100w10_dat", maximise = c(FALSE, TRUE))
eaftest("wrots_l10w100_dat", "wrots_l100w10_dat", maximise = c(TRUE, TRUE))
})
