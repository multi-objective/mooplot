# This file is loaded automatically by testthat (supposedly)
extdata_path <- function(file)
  file.path(system.file(package = "moocore"), "extdata", file)

read_extdata <- function(file) read_datasets(extdata_path(file))

maximise2str <- function(maximise) {
  maximise <- rep_len(maximise, 2L)
  paste0(ifelse(maximise[1L],"max", "min"),
    ifelse(maximise[2L],"max", "min"))
}

canonical_name <- function(s)
  gsub("_dat", "", gsub(".xz", "", s, fixed=TRUE), fixed = TRUE)

## help_plot <- function(A, B)
## {
##   library(ggplot2)
##   x <- rbind(cbind(as.data.frame(A), algo="A"),cbind(as.data.frame(B), algo="B"))
##   DIFF <- eafdiff(A,B, rectangles=FALSE)
##   rectangles <- eafdiff(A,B, rectangles=TRUE)
##   colnames(DIFF) <- c("x","y", "color")
##   p <- ggplot(data=x) + geom_point(aes(x=V1,y=V2, color=algo, shape=as.factor(set))) + scale_shape_manual(values=c(0, 9, 1:8))
##   p <- p + geom_rect(data=as.data.frame(rectangles), aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=as.factor(diff)), color="black", alpha=0.5)
##   p <- p + geom_text(data=as.data.frame(DIFF), aes(x=x,y=y,label=color), nudge_x = 0.05, nudge_y = 0.05)
##   print(p)
## }

# From: https://testthat.r-lib.org/reference/expect_snapshot_file.html
# To use expect_snapshot_file() you'll typically need to start by writing
# a helper function that creates a file from your code, returning a path
save_png <- function(code, width = 400, height = 400, scale = c(1,1)) {
  path <- tempfile(fileext = ".png")
  withr::with_png(path, width = scale[1L] * width, height = scale[2L] * height, {
    code
  })
  path
}

# You'd then also provide a helper that skips tests where you can't
# be sure of producing exactly the same output
expect_snapshot_plot <- function(name, code, scale = c(1,1)) {
  # Other packages might affect results
  #skip_if_not_installed("ggplot2", "2.0.0")
  # Or maybe the output is different on some operation systems
  #skip_on_os("windows")
  skip_on_ci() # Skip for now until we implement this: https://github.com/tidyverse/ggplot2/blob/main/tests/testthat/helper-vdiffr.R

  # You'll need to carefully think about and experiment with these skips
  name <- paste0(canonical_name(name), ".png")
  # Announce the file before touching `code`. This way, if `code`
  # unexpectedly fails or skips, testthat will not auto-delete the
  # corresponding snapshot file.
  testthat::announce_snapshot_file(name = name)
  path <- save_png(code, scale = scale)
  testthat::expect_snapshot_file(path, name = name)
}
