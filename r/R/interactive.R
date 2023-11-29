#' Interactively choose according to empirical attainment function differences
#'
#' Creates the same plot as [eafdiffplot()] but waits for the user to click in
#' one of the sides. Then it returns the rectangles the give the differences in
#' favour of the chosen side. These rectangles may be used for interactive
#' decision-making as shown in \citet{DiaLop2020ejor}. The function
#' [moocore::choose_eafdiff()] may be used in a non-interactive context.
#'
#' @inheritParams eafdiffplot
# @param data.left,data.right Data frames corresponding to the input data of
#   left and right sides, respectively. Each data frame has at least three
#   columns, the third one being the set of each point. See also
#   [read_datasets()].
#
# @param intervals (`integer(1)`|`character()`) \cr The absolute range of the
#   differences \eqn{[0, 1]} is partitioned into the number of intervals
#   provided. If an integer is provided, then labels for each interval are
#   computed automatically. If a character vector is provided, its length is
#   taken as the number of intervals.
#'
#' @param ... Other graphical parameters are passed down to
#'   [eafdiffplot()].
#'
#'
#' @return `matrix` where the first 4 columns give the coordinates of two
#'   corners of each rectangle and the last column. In both cases, the last
#'   column gives the positive differences in favor of the chosen side.
#'
#' @seealso    [moocore::read_datasets()], [eafdiffplot()], [moocore::whv_rect()]
#'
#' @examples
#'
#' \donttest{
#' library(moocore)
#' extdata_dir <- system.file(package="moocore", "extdata")
#' A1 <- read_datasets(file.path(extdata_dir, "wrots_l100w10_dat"))
#' A2 <- read_datasets(file.path(extdata_dir, "wrots_l10w100_dat"))
#' if (interactive()) {
#'   rectangles <- choose_eafdiffplot(A1, A2, intervals = 5)
#' } else { # Choose A1
#'   rectangles <- eafdiff(A1, A2, intervals = 5, rectangles = TRUE)
#'   rectangles <- choose_eafdiff(rectangles, left = TRUE)
#' }
#' reference <- c(max(A1[, 1], A2[, 1]), max(A1[, 2], A2[, 2]))
#' x <- split.data.frame(A1[,1:2], A1[,3])
#' hv_A1 <- sapply(split.data.frame(A1[, 1:2], A1[, 3]),
#'                  hypervolume, reference=reference)
#' hv_A2 <- sapply(split.data.frame(A2[, 1:2], A2[, 3]),
#'                  hypervolume, reference=reference)
#' boxplot(list(A1=hv_A1, A2=hv_A2), main = "Hypervolume")
#'
#' whv_A1 <- sapply(split.data.frame(A1[, 1:2], A1[, 3]),
#'                  whv_rect, rectangles=rectangles, reference=reference)
#' whv_A2 <- sapply(split.data.frame(A2[, 1:2], A2[, 3]),
#'                  whv_rect, rectangles=rectangles, reference=reference)
#' boxplot(list(A1=whv_A1, A2=whv_A2), main = "Weighted hypervolume")
#' }
#'
#'@references
#' \insertAllCited{}
#' @concept eaf
#' @export
choose_eafdiffplot <- function(data_left, data_right, intervals = 5,
                               maximise = c(FALSE, FALSE),
                               title_left = deparse(substitute(data_left)),
                               title_right = deparse(substitute(data_right)),
                               ...)
{
  withr::local_options(locatorBell = FALSE)
  eafdiffplot(data_left, data_right, title_left= title_left, title_right = title_right,
              intervals = intervals, maximise = maximise, ...)
  # FIXME: Avoid calculating eafdiff twice.
  DIFF <- eafdiff(data_left, data_right, intervals = intervals, maximise = maximise,
                  rectangles = TRUE)

  coord <- grid::grid.locator("npc")
  left <- coord$x[[1]] < 0.5
  if (left) cat("LEFT!\n") else cat("RIGHT!\n")
  choose_eafdiff(DIFF, left=left)
}
