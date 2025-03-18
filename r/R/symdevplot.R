#' Plot the symmetric deviation function.
#'
#' The symmetric deviation function is the probability for a given target in
#' the objective space to belong to the symmetric difference between the
#' Vorob'ev expectation and a realization of the (random) attained set.
#'
#' @inheritParams moocore::vorobT
#'
#' @param VE,threshold Vorob'ev expectation and threshold, e.g., as returned
#'   by [moocore::vorobT()].
#'
#' @param nlevels (`integer(1)`)\cr Number of levels in which is divided the range of the
#'   symmetric deviation.
#'
#' @param ve.col Plotting parameters for the Vorob'ev expectation.
#'
#' @param xlim,ylim,main Graphical parameters, see
#' [`plot.default()`][graphics::plot.default()].
#'
#' @param legend.pos The position of the legend, see
#'   [`legend()`][graphics::legend()]. A value of `"none"` hides the legend.
#'
#' @param col.fun Function that creates a vector of `n` colors, see
#'   [`heat.colors()`][grDevices::heat.colors()].
#'
#' @return No return value, called for side effects
#'
#' @author Mickael Binois
#'
#' @seealso    [moocore::vorobT()] [moocore::vorobDev()] [eafplot()]
#'
#' @examples
#' data(CPFs, package = "moocore")
#' res <- moocore::vorobT(CPFs, reference = c(2, 200))
#' print(res$threshold)
#'
#' ## Display Vorob'ev expectation and attainment function
#' # First style
#' eafplot(CPFs[,1:2], sets = CPFs[,3], percentiles = c(0, 25, 50, 75, 100, res$threshold),
#'         main = substitute(paste("Empirical attainment function, ",beta,"* = ", a, "%"),
#'                           list(a = formatC(res$threshold, digits = 2, format = "f"))))
#'
#' # Second style
#' eafplot(CPFs[,1:2], sets = CPFs[,3], percentiles = c(0, 20, 40, 60, 80, 100),
#'         col = gray(seq(0.8, 0.1, length.out = 6)^0.5), type = "area",
#'         legend.pos = "bottomleft", extra.points = res$VE, extra.col = "cyan",
#'         extra.legend = "VE", extra.lty = "solid", extra.pch = NA, extra.lwd = 2,
#'         main = substitute(paste("Empirical attainment function, ",beta,"* = ", a, "%"),
#'                           list(a = formatC(res$threshold, digits = 2, format = "f"))))
#' # Vorob'ev deviation
#' VD <- moocore::vorobDev(CPFs, reference = c(2, 200), VE = res$VE)
#' # Display the symmetric deviation function.
#' symdevplot(CPFs, VE = res$VE, threshold = res$threshold, nlevels = 11)
#' # Levels are adjusted automatically if too large.
#' symdevplot(CPFs, VE = res$VE, threshold = res$threshold, nlevels = 200, legend.pos = "none")
#'
#' # Use a different palette.
#' symdevplot(CPFs, VE = res$VE, threshold = res$threshold, nlevels = 11, col.fun = heat.colors)
#'
#' @references
#'
#' \insertRef{BinGinRou2015gaupar}{moocore}
#'
#' C. Chevalier (2013), Fast uncertainty reduction strategies relying on
#' Gaussian process models, University of Bern, PhD thesis.
#'
#' \insertRef{Molchanov2005theory}{moocore}
#'
#' @concept eaf
#' @export
# FIXME: Implement "add=TRUE" option that just plots the lines,points or
# surfaces and does not create the plot nor the legend (but returns the info
# needed to create a legend), so that one can use the function to add stuff to
# another plot.
symdevplot <- function(x, sets, VE, threshold, nlevels = 11,
                       ve.col = "blue", xlim = NULL, ylim = NULL,
                       legend.pos = "topright", main = "Symmetric deviation function",
                       col.fun = function(n) gray(seq(0, 0.9, length.out = n)^2))
{
  if (missing(sets)) {
    sets <- x[, ncol(x)]
    x <- x[, -ncol(x), drop=FALSE]
  }
  # FIXME: These maybe should be parameters of the function in the future.
  maximise <- c(FALSE, FALSE)
  xaxis_side <- "below"
  yaxis_side <- "left"
  log <- ""
  if (is.null(colnames(x))) {
    xlab <- "objective 1"
    ylab <- "objective 2"
  } else {
    xlab <- colnames(x)[1L]
    ylab <- colnames(x)[2L]
  }

  las <- par("las")
  sci.notation <- FALSE
  nlevels <- min(length(unique.default(sets)) - 1L, nlevels)
  seq_levs <- round(seq(0, 100, length.out = nlevels), 4L)
  threshold <- round(threshold, 4L)
  levs <- sort.int(unique.default(c(threshold, seq_levs)))
  attsurfs <- moocore::eaf_as_list(
    moocore::eaf(x, sets, percentiles = levs, maximise = maximise))

  # Denote p_n the attainment probability, the value of the symmetric
  # difference function is p_n if p_n < alpha (Vorob'ev threshold) and 1 - p_n
  # otherwise. Therefore, there is a sharp transition at alpha.  For example,
  # for threshold = 44.5 and 5 levels, we color the following intervals:
  #
  # [0, 25) [25, 44.9) [44.9, 50) [50, 75) [75, 100]
  #
  # with the following colors:
  #
  # [0, 25) [25, 50) [50, 75) [25, 50) [0, 25)
  max_interval <- max(which(seq_levs < max(100 - threshold, threshold)))
  colscale <- seq_levs[1:max_interval]
  # Reversed so that darker colors are associated to higher values
  names(colscale) <- rev(col.fun(max_interval))
  cols <- c(names(colscale[colscale < threshold]),
            rev(names(colscale[1:max(which(colscale < 100 - threshold))])),
            "#FFFFFF") # To have white after worst case
  names(levs) <- cols

  if (is.null(xlim))
    xlim <- range_finite(x[,1L])
  if (is.null(ylim))
    ylim <- range_finite(x[,2L])
  extreme <- get_extremes(xlim, ylim, maximise, log = log)

  plot(xlim, ylim, type = "n", xlab = "", ylab = "",
       xlim = xlim, ylim = ylim, log = log, axes = FALSE, las = las,
       main = main,
       panel.first = {
         plot_eaf_full_area(attsurfs, extreme = extreme, maximise = maximise, col = cols)
         # We place the axis after so that we get grid lines.
         plot_eaf_axis (xaxis_side, xlab, las = las, sci.notation = sci.notation)
         plot_eaf_axis (yaxis_side, ylab, las = las, sci.notation = sci.notation,
                        line = 2.2)
         plot_eaf_full_lines(list(VE), extreme, maximise,
                             col = ve.col, lty = 1, lwd = 2)
       })

  # Use first_open to print "(0,X)", because the color for 0 is white.
  intervals <- seq_intervals_labels(seq_levs, first_open = TRUE)
  intervals <- intervals[seq_len(max_interval)]
  names(intervals) <- names(colscale)
  #names(intervals) <- names(colscale[1:max_interval])
  if (is.na(pmatch(legend.pos, "none")))
    legend(legend.pos, legend = c("VE", intervals), fill = c(ve.col, names(intervals)),
           bg="white", bty="n", xjust=0, yjust=0, cex=0.9)
  box()
}
