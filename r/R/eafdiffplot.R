#' Plot empirical attainment function differences
#'
#' Plot the differences between the empirical attainment functions (EAFs) of two
#' data sets as a two-panel plot, where the left side shows the values of
#' the left EAF minus the right EAF and the right side shows the
#' differences in the other direction.
#'
#' @inheritParams eafplot
#'
#' @param data_left,data_right Data frames corresponding to the input data of
#'   left and right sides, respectively. Each data frame has at least three
#'   columns, the third one being the set of each point. See also
#'   [read_datasets()].
#'
#' @param col A character vector of three colors for the magnitude of the
#'   differences of 0, 0.5, and 1. Intermediate colors are computed
#'   automatically given the value of `intervals`. Alternatively, a function
#'   such as [viridisLite::viridis()] that generates a colormap given an
#'   integer argument.
#'
#' @param intervals (`integer(1)`|`character()`)\cr The absolute range of the
#'   differences \eqn{[0, 1]} is partitioned into the number of intervals
#'   provided. If an integer is provided, then labels for each interval are
#'   computed automatically. If a character vector is provided, its length is
#'   taken as the number of intervals.
#'
#' @param percentiles The percentiles of the EAF of each side that will be
#'   plotted as attainment surfaces. `NA` does not plot any. See
#'   [eafplot()].
#'
#' @param full.eaf Whether to plot the EAF of each side instead of the
#'   differences between the EAFs.
#'
#' @param type (`"points"`|`"area"`)\cr Whether the EAF differences are plotted
#'   as points (`"points"`) or whether to color the areas that have at least a
#'   certain value (`"area"`).
#'
#' @param legend.pos (`character(1)`)\cr The position of the legend. See
#'   [legend()].  A value of `"none"` hides the legend.
#'
#' @param title_left,title_right Title for left and right panels, respectively.
#'
#' @param xlim,ylim,cex,cex.lab,cex.axis Graphical parameters, see
#'   [plot.default()].
#'
#' @param grand.lines Whether to plot the grand-best and grand-worst
#'   attainment surfaces.
#'
#' @param sci.notation Generate prettier labels
#'
#' @param left.panel.last,right.panel.last An expression to be evaluated after
#'   plotting has taken place on each panel (left or right). This can be useful
#'   for adding points or text to either panel.  Note that this works by lazy
#'   evaluation: passing this argument from other `plot` methods may well
#'   not work since it may be evaluated too early.
#'
#' @param ... Other graphical parameters are passed down to
#'   [plot.default()].
#'
#' @details
#'
#'   This function calculates the differences between the EAFs of two data
#'   sets, and plots on the left the differences in favour of the left data
#'   set, and on the right the differences in favour of the right data set. By
#'   default, it also plots the grand best and worst attainment surfaces, that
#'   is, the 0%- and 100%-attainment surfaces over all data. These two surfaces
#'   delimit the area where differences may exist. In addition, it also plots
#'   the 50%-attainment surface of each data set.
#'
#'   With `type = "point"`, only the points where there is a change in the
#'   value of the EAF difference are plotted. This means that for areas where
#'   the EAF differences stays constant, the region will appear in white even
#'   if the value of the differences in that region is large. This explains
#'   "white holes" surrounded by black points.
#'
#'   With `type = "area"`, the area where the EAF differences has a certain
#'   value is plotted.  The idea for the algorithm to compute the areas was
#'   provided by Carlos M. Fonseca.  The implementation uses R polygons, which
#'   some PDF viewers may have trouble rendering correctly (See
#'   \url{https://cran.r-project.org/doc/FAQ/R-FAQ.html#Why-are-there-unwanted-borders}).
#'   Plots (should) look correct when printed.
#'
#'   Large differences that appear when using `type = "point"` may
#'   seem to disappear when using `type = "area"`. The explanation is
#'   the points size is independent of the axes range, therefore, the
#'   plotted points may seem to cover a much larger area than the actual
#'   number of points. On the other hand, the areas size is plotted with
#'   respect to the objective space, without any extra borders. If the
#'   range of an area becomes smaller than one-pixel, it won't be
#'   visible. As a consequence, zooming in or out certain regions of the plots
#'   does not change the apparent size of the points, whereas it affects
#'   considerably the apparent size of the areas.
#'
#'
#' @return Returns a representation of the EAF differences (invisibly).
#'
#' @seealso    [read_datasets()] [eafplot()] [pdf_crop()]
#'
#' @examples
#' ## NOTE: The plots in the website look squashed because of how pkgdown
#' ## generates them. They should look fine when you generate them yourself.
#' extdata_dir <- system.file(package="moocore", "extdata")
#' A1 <- read_datasets(file.path(extdata_dir, "ALG_1_dat.xz"))
#' A2 <- read_datasets(file.path(extdata_dir, "ALG_2_dat.xz"))
#' \donttest{# These take time
#' eafdiffplot(A1, A2, full.eaf = TRUE)
#' if (requireNamespace("viridisLite", quietly=TRUE)) {
#'   viridis_r <- function(n) viridisLite::viridis(n, direction=-1)
#'   eafdiffplot(A1, A2, type = "area", col = viridis_r)
#' } else {
#'   eafdiffplot(A1, A2, type = "area")
#' }
#' A1 <- read_datasets(file.path(extdata_dir, "wrots_l100w10_dat"))
#' A2 <- read_datasets(file.path(extdata_dir, "wrots_l10w100_dat"))
#' eafdiffplot(A1, A2, type = "point", sci.notation = TRUE, cex.axis=0.6)
#' }
#' # A more complex example
#' DIFF <- eafdiffplot(A1, A2, col = c("white", "blue", "red"), intervals = 5,
#'                     type = "point",
#'                     title_left=expression("W-RoTS," ~ lambda==100 * "," ~ omega==10),
#'                     title_right=expression("W-RoTS," ~ lambda==10 * "," ~ omega==100),
#'                     right.panel.last={
#'                       abline(a = 0, b = 1, col = "red", lty = "dashed")})
#'
#' ## Save the values to a file.
#' # DIFF$right[,3] <- -DIFF$right[,3]
#' # write.table(rbind(DIFF$left,DIFF$right),
#' #             file = "wrots_l100w10_dat-wrots_l10w100_dat-diff.txt",
#' #             quote = FALSE, row.names = FALSE, col.names = FALSE)
#'
#' @references
#' \insertRef{Grunert01}{moocore}
#'
#' \insertRef{LopPaqStu09emaa}{moocore}
#' @concept eaf
#' @export
eafdiffplot <-
  function(data_left, data_right,
           col = c("#FFFFFF", "#808080","#000000"),
           intervals = 5L,
           percentiles = 50,
           full.eaf = FALSE,
           type = "area",
           legend.pos = if (full.eaf) "bottomleft" else "topright",
           maximise = c(FALSE, FALSE),
           title_left,
           title_right,
           xlim = NULL, ylim = NULL,
           cex = par("cex"), cex.lab = par("cex.lab"), cex.axis = par("cex.axis"),
           grand.lines = TRUE,
           sci.notation = FALSE,
           left.panel.last = NULL,
           right.panel.last = NULL,
           ...)
{
  type <- match.arg (type, c("point", "area"))
  if (missing(title_left)) title_left <- deparse1(substitute(data_left))
  if (missing(title_right)) title_right <- deparse1(substitute(data_right))
  # FIXME: check that it is either an integer or a character vector.
  if (length(intervals) == 1L) {
    intervals <- seq_intervals_labels(
      round(seq(0, 1, length.out = 1 + intervals), 4L), digits = 1L)
  }
  if (is.function(col)) { # It is a color-map, like viridis()
    col <- col(length(intervals))
  } else {
    if (length(col) != 3L)
      stop ("'col' is either three colors (minimum, medium maximum) or a function that produces a colormap")
    col <- colorRampPalette(col)(length(intervals))
  }
  # FIXME: The lowest color must be white (it should be the background).
  col[1L] <- "white"

  unique_counts <- function(x) as.vector(table(x))

  sets_left <- data_left[, ncol(data_left)]
  cumsizes_left <- cumsum(unique_counts(sets_left))
  data_left <- data_left[order(sets_left), -ncol(data_left), drop=FALSE]
  data_left <- as_double_matrix(data_left)

  sets_right <- data_right[, ncol(data_right)]
  cumsizes_right <- cumsum(unique_counts(sets_right))
  data_right <- data_right[order(sets_right), -ncol(data_right), drop=FALSE]
  data_right <- as_double_matrix(data_right)

  maximise <- as.logical(maximise)
  if (any(maximise)) {
    data_left <- transform_maximise(data_left, maximise)
    data_right <- transform_maximise(data_right, maximise)
  }

  attsurfs_left <- attsurfs_right <- list()
  if (!any(is.na(percentiles))) {
    attsurfs_left <- compute_attsurfs(data_left, cumsizes_left, percentiles = percentiles, maximise = maximise)
    attsurfs_right <- compute_attsurfs(data_right, cumsizes_right, percentiles = percentiles, maximise = maximise)
  }

  grand_best_worst <- function(data_left, data_right, cumsizes_left, cumsizes_right, maximise) {
    cumsizes.combined <- c(cumsizes_left, cumsizes_left[length(cumsizes_left)] + cumsizes_right)
    compute_attsurfs(rbind(data_left, data_right),
      cumsizes = cumsizes.combined, percentiles = c(0, 100), maximise)
  }

  # best = grand[["0"]], worst = grand[["100"]]
  grand <- grand_best_worst(data_left, data_right, cumsizes_left, cumsizes_right, maximise)

  if (full.eaf) {
    if (type == "area") {
      lower_boundaries <- 0L:(length(intervals)-1L) * (100 / length(intervals))
      diff_left <- compute_eaf_call(data_left, cumsizes = cumsizes_left, percentiles = lower_boundaries)
      diff_right <- compute_eaf_call(data_right, cumsizes = cumsizes_right, percentiles = lower_boundaries)
    } else if (type == "point") {
      diff_left <- compute_eaf_call(data_left, cumsizes = cumsizes_left, percentiles = NULL)
      diff_right <- compute_eaf_call(data_right, cumsizes = cumsizes_right, percentiles = NULL)
      # Since plot_eafdiff_side uses floor to calculate the color, and we want
      # color[100] == color[99].
      diff_left[diff_left[,3L] == 100, 3L] <- 99
      diff_right[diff_right[,3L] == 100, 3L] <- 99
    }
    # Convert percentile into color index
    diff_left[,3L] <- diff_left[,3L] * length(intervals) / 100
    diff_right[,3L] <- diff_right[,3L] * length(intervals) / 100
    #remove(data_left,data_right,data.combined) # Free memory?
  } else {
    DIFF <- compute_eafdiff_call (data_left, data_right,
      cumsizes_x = cumsizes_left,
      cumsizes_y = cumsizes_right,
      intervals = length(intervals),
      ret = if (type == "area") "polygons" else "points")
    if (type == "area") {
      diff_left <- DIFF$left
      diff_right <- DIFF$right
    } else {
      ## FIXME: Do this computation in C code. See compute_eafdiff_area_C
      eafval <- DIFF[, ncol(DIFF)]
      diff_left <- unique(DIFF[ eafval >= 1L, , drop=FALSE])
      diff_right <- unique(DIFF[ eafval <= -1L, , drop=FALSE])
      diff_right[, ncol(DIFF)] <- -diff_right[, ncol(DIFF)]
    }
  }
  if (any(maximise)) {
    # For !full.eaf && type == "area", str(eafdiff) is a polygon:
    ##  $  num [, 1:2]
    ##    - attr(*, "col")= num []
    diff_left[, c(1L,2L)] <- transform_maximise(diff_left[, c(1L,2L), drop=FALSE], maximise)
    diff_right[, c(1L,2L)] <- transform_maximise(diff_right[, c(1L,2L), drop=FALSE], maximise)
  }

  if (is.null(xlim))
    xlim <- .range(c(.range(grand[["0"]][,1L]), .range(grand[["100"]][,1L]),
      range_finite(diff_left[,1L]), range_finite(diff_right[,1L])))
  if (is.null(ylim))
    ylim <- .range(c(.range(grand[["0"]][,2L]), .range(grand[["100"]][,2L]),
      range_finite(diff_left[,2L]), range_finite(diff_right[,2L])))

  # FIXME: This does not generate empty space between the two plots, but the
  # plots are not squared.
  layout(matrix(c(1L,2L), ncol=2L, byrow=TRUE), respect=TRUE)
  bottommar <- 5L
  topmar   <- 4L
  leftmar  <- 4L
  rightmar <- 4L

  # FIXME: This generates empty spaces between the two plots. How to ensure
  # that the side-by-side plots are kept together?
  ## layout(matrix(1:2, ncol = 2))
  ## par (pty = 's') # Force it to be square
  ## bottommar <- 5
  ## topmar   <- 4
  ## leftmar  <- 4
  ## rightmar <- 4

  # cex.axis is multiplied by cex, but cex.lab is not.
  withr::local_par(cex = cex, cex.lab = cex.lab, cex.axis = cex.axis
    , mar = c(bottommar, leftmar, topmar, 0)
    , lab = c(10,5,7)
    , las = 0
      )
  plot_eafdiff_side (diff_left,
                     attsurfs = if (grand.lines) c(grand["0"], attsurfs_left, grand["100"]) else attsurfs_left,
                     col = col,
                     type = type, full.eaf = full.eaf,
                     title = title_left,
                     xlim = xlim, ylim = ylim,
                     side = "left", maximise = maximise,
                     sci.notation = sci.notation, ...)

  if (is.na(pmatch(legend.pos,"none"))){
    #nchar(legend.pos) > 0 && !(legend.pos %in% c("no", "none"))) {
    legend(x = legend.pos, y = NULL,
           rev(intervals), rev(col),
           bg = "white", bty = "n", xjust=0, yjust=0, cex=0.85)
  }
  left.panel.last

  par(mar = c(bottommar, 0, topmar, rightmar))
  plot_eafdiff_side (diff_right,
                     attsurfs = if (grand.lines) c(grand["0"], attsurfs_right, grand["100"]) else attsurfs_right,
                     col = col,
                     type = type, full.eaf = full.eaf,
                     title = title_right,
                     xlim = xlim, ylim = ylim,
                     side = "right", maximise = maximise,
                     sci.notation = sci.notation, ...)
  right.panel.last
  invisible(list(left=diff_left, right=diff_right))
}

plot_eafdiff_side <- function (eafdiff, attsurfs = list(),
                               col,
                               side = stop("Argument 'side' is required"),
                               type = "point",
                               xlim = NULL, ylim = NULL, log = "",
                               las = par("las"),
                               full.eaf = FALSE,
                               title = "",
                               maximise = c(FALSE, FALSE),
                               xlab = "objective 1", ylab = "objective 2",
                               sci.notation = FALSE,
                               ...)
{
  type <- match.arg (type, c("point", "area"))
  side <- match.arg (side, c("left", "right"))
  xaxis_side <- if (side == "left") "below" else "above"
  yaxis_side <- if (side == "left") "left" else "right"

  # We do not paint with the same color as the background since this
  # will override the grid lines.
  col[col %in% c("white", "#FFFFFF")] <- "transparent"

  extreme <- get_extremes(xlim, ylim, maximise, log)
  yscale <- 1
  ## FIXME log == "y" and yscaling
  #    yscale <- 60
  ## if (yscale != 1) {
  ##   # This doesn't work with polygons.
  ##   stopifnot (full.eaf || type == "point")

  ##   eafdiff[,2] <- eafdiff[,2] / yscale
  ##   attsurfs <- lapply (attsurfs, function (x)
  ##                       { x[,2] <- x[,2] / yscale; x })
  ##   ylim <- ylim / yscale
  ##   if (log == "y") extreme[2] <- 1
  ## }
  plot(xlim, ylim, type = "n", xlab = "", ylab = "",
       xlim = xlim, ylim = ylim, log = log, axes = FALSE, las = las,
       panel.first = ({
         plot_eaf_axis (xaxis_side, xlab, las = las, sci.notation = sci.notation)
         plot_eaf_axis (yaxis_side, ylab, las = las, sci.notation = sci.notation,
                        line = 2.2)

         if (nrow(eafdiff)) {
           # For !full.eaf && type == "area", str(eafdiff) is a polygon:
           ##  $  num [, 1:2]
           ##    - attr(*, "col")= num []

           # Colors are correct for !full.eaf && type == "area"
           if (full.eaf || type == "point") {
             diff_values <- eafdiff[,3L]
             eafdiff <- eafdiff[, c(1L,2L), drop=FALSE]
             # FIXME: This is wrong, we should color (0.0, 1] with col[1], then (1, 2]
             # with col[1], etc, so that we never color the value 0.0 but we always
             # color the maximum value color without having to force it.

             # Why flooring and not ceiling? If a point has value 2.05, it should
             # be painted with color 2 rather than 3.
             # +1 because col[1] is white ([0,1)).
             diff_values <- floor(diff_values) + 1
             if (nunique(diff_values) > length(col)) {
               stop ("Too few colors: length(unique(diff_values)) > length(col)")
             }
           }
           if (type == "area") {
             if (full.eaf) {
               plot_eaf_full_area(split.data.frame(eafdiff, diff_values),
                                   extreme, maximise, col)
             } else {
               polycol <- attr(eafdiff, "col")
               eafdiff[,1L] <- replace_inf(eafdiff[,1L], value = extreme[1L])
               eafdiff[,2L] <- replace_inf(eafdiff[,2L], value = extreme[2L])
               #print(unique(polycol))
               #print(length(col))
               ## The maximum value should also be painted.
               # FIXME: How can this happen???
               polycol[polycol > length(col)] <- length(col)
               ### For debugging:
               ## poly_id <- head(1 + cumsum(is.na(eafdiff[,1])),n=-1)
               ## for(i in which(polycol == 10)) {
               ##   c_eafdiff <- eafdiff[i == poly_id, ]
               ##   polygon(c_eafdiff[,1], c_eafdiff[,2], border = FALSE, col = col[polycol[i]])
               ## }
               #print(eafdiff)
               #print(col[polycol])
               # FIXME: This reduces the number of artifacts but increases the memory consumption of embedFonts(filename) until it crashes.
               #polygon(eafdiff[,1], eafdiff[,2], border = col[polycol], lwd=0.1, col = col[polycol])
               polygon(eafdiff[,1L], eafdiff[,2L], border = col[polycol], col = col[polycol])
             }
           } else {
             ## The maximum value should also be painted.
             diff_values[diff_values > length(col)] <- length(col)
             eafdiff <- eafdiff[order(diff_values, decreasing = FALSE), , drop=FALSE]
             diff_values <- diff_values[order(diff_values, decreasing = FALSE)]
             points(eafdiff[,1L], eafdiff[,2L], col = col[diff_values], type = "p", pch=20)
           }
         }
       }), ...)

  lty <- c("solid", "dashed")
  lwd <- 1L
  col <- if (type == "area" && full.eaf) c("black", "black", "white") else "black"

  plot_eaf_full_lines(attsurfs, extreme, maximise, col = col, lty = lty, lwd = lwd)
  mtext(title, 1, line = 3.5, cex = par("cex.lab"), las = 0, font = 2)
  box()
}

compute_attsurfs <- function(x, cumsizes, percentiles, maximise)
{
  x <- compute_eaf_call(x, cumsizes = cumsizes, percentiles = percentiles)
  if (any(maximise))
    x[,-ncol(x)] <- transform_maximise(x[, -ncol(x), drop=FALSE], maximise)
  eaf_as_list(x)
}
