source("helper-common.R")

expect_snapshot_eafdiffplot <- function(file, ...)
  expect_snapshot_plot(file, scale = c(2,1), eafdiffplot(...))

eaftest <- function(a, b, maximise = c(FALSE, FALSE),
                    title_left = canonical_name(a),
                    title_right = canonical_name(b), ...) {
  A1 <- read_extdata(a)
  A2 <- read_extdata(b)
  if (any(maximise)) {
    A1[, which(maximise)] <- -A1[, which(maximise)]
    A2[, which(maximise)] <- -A2[, which(maximise)]
  }
  expect_snapshot_eafdiffplot(paste0(a, "-", b, "-area-", maximise2str(maximise)),
    A1, A2, type = "area", maximise = maximise, title_left = title_left, title_right = title_right, ...)
  expect_snapshot_eafdiffplot(paste0(a, "-", b, "-point-", maximise2str(maximise)),
    A1, A2, type = "point", maximise = maximise, title_left = title_left, title_right = title_right, ...)
  expect_snapshot_eafdiffplot(paste0(a, "-", b, "-full-", maximise2str(maximise)),
    A1, A2, full.eaf = TRUE, maximise = maximise, title_left = title_left, title_right = title_right, ...)
}


test_that("eafdiffplot", {
  skip_on_cran()
  ## FIXME: We need smaller data!
  eaftest("tpls.xz", "rest.xz")
  eaftest("wrots_l10w100_dat", "wrots_l100w10_dat")
  eaftest("wrots_l10w100_dat", "wrots_l100w10_dat", maximise = c(TRUE, FALSE))
  eaftest("wrots_l10w100_dat", "wrots_l100w10_dat", maximise = c(FALSE, TRUE))
  eaftest("wrots_l10w100_dat", "wrots_l100w10_dat", maximise = c(TRUE, TRUE))
  # This is what tools/create-figures.R produces
  eaftest("ALG_1_dat.xz", "ALG_2_dat.xz", title_left = "Algorithm 1", title_right = "Algorithm 2")
  eaftest("wrots_l100w10_dat", "wrots_l10w100_dat",
    col = colorRampPalette(c("blue", "red")), intervals = 10,
    title_left = expression("W-RoTS, " * lambda * "=" * 100 * ", " * omega * "=" * 10),
    title_right= expression("W-RoTS, " * lambda * "=" * 10 * ", " * omega * "=" * 100))
})
