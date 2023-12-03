#' Plot empirical attainment function differences 
#' 
#' Plot the differences between the empirical attainment functions (EAFs) of two
#' data sets as a two-panel plot, where the left side shows the values of
#' the left EAF minus the right EAF and the right side shows the
#' differences in the other direction.
#' 
#' @param data.left,data.right Data frames corresponding to the input data of
#'   left and right sides, respectively. Each data frame has at least three
#'   columns, the third one being the set of each point. See also
#'   [read_datasets()].
#' 
#' @param col A character vector of three colors for the magnitude of the
#'   differences of 0, 0.5, and 1. Intermediate colors are computed
#'   automatically given the value of `intervals`. Alternatively, a function
#'   such as [viridisLite::viridis()] that generates a colormap given an integer
#'   argument.
#' 
#' @param intervals (`integer(1)`|`character()`) \cr The
#'   absolute range of the differences \eqn{[0, 1]} is partitioned into the number
#'   of intervals provided. If an integer is provided, then labels for each
#'   interval are  computed automatically. If a character vector is
#'   provided, its length is taken as the number of intervals.
#' 
#' @param percentiles The percentiles of the EAF of each side that will be
#'   plotted as attainment surfaces. `NA` does not plot any. See
#'   [eafplot()].
#' 
#' @param full.eaf Whether to plot the EAF of each side instead of the
#'   differences between the EAFs.
#' 
#' @param type Whether the EAF differences are plotted as points
#'   (\samp{points}) or whether to color the areas that have at least a
#'   certain value (\samp{area}).
#' 
#'@param legend.pos The position of the legend. See [legend()].  A value of
#'   `"none"` hides the legend.
#' 
#'@param title.left,title.right Title for left and right panels, respectively.
#'  
#' @param xlim,ylim,cex,cex.lab,cex.axis Graphical parameters, see
#'   [plot.default()].
#' 
#' @template arg_maximise
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
#'   This function calculates the differences between the EAFs of two
#'   data sets, and plots on the left the differences in favour
#'   of the left data set, and on the right the differences in favour of
#'   the right data set. By default, it also plots the grand best and worst
#'   attainment surfaces, that is, the 0%- and 100%-attainment surfaces
#'   over all data. These two surfaces delimit the area where differences
#'   may exist. In addition, it also plots the 50%-attainment surface of
#'   each data set.
#'   
#'   With `type = "point"`, only the points where there is a change in
#'   the value of the EAF difference are plotted. This means that for areas
#'   where the EAF differences stays constant, the region will appear in
#'   white even if the value of the differences in that region is
#'   large. This explains "white holes" surrounded by black
#'   points.
#'
#'   With `type = "area"`, the area where the EAF differences has a
#'   certain value is plotted.  The idea for the algorithm to compute the
#'   areas was provided by Carlos M. Fonseca.  The implementation uses R
#'   polygons, which some PDF viewers may have trouble rendering correctly
#'   (See
#'   \url{https://cran.r-project.org/doc/FAQ/R-FAQ.html#Why-are-there-unwanted-borders}). Plots (should) look correct when printed.
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
#'                     title.left=expression("W-RoTS," ~ lambda==100 * "," ~ omega==10),
#'                     title.right=expression("W-RoTS," ~ lambda==10 * "," ~ omega==100),
#'                     right.panel.last={
#'                       abline(a = 0, b = 1, col = "red", lty = "dashed")})
#' DIFF$right[,3] <- -DIFF$right[,3]
#' 
#' ## Save the values to a file.
#' # write.table(rbind(DIFF$left,DIFF$right),
#' #             file = "wrots_l100w10_dat-wrots_l10w100_dat-diff.txt",
#' #             quote = FALSE, row.names = FALSE, col.names = FALSE)
#'
#' @concept visualisation
#'@export
eafdiffplot <-
  function(data.left, data.right,
           col = c("#FFFFFF", "#808080","#000000"),
           intervals = 5,
           percentiles = c(50),
           full.eaf = FALSE,
           type = "area",
           legend.pos = if (full.eaf) "bottomleft" else "topright",
           title.left = deparse(substitute(data.left)),
           title.right = deparse(substitute(data.right)),
           xlim = NULL, ylim = NULL,
           cex = par("cex"), cex.lab = par("cex.lab"), cex.axis = par("cex.axis"),
           maximise = c(FALSE, FALSE),
           grand.lines = TRUE,
           sci.notation = FALSE,
           left.panel.last = NULL,
           right.panel.last = NULL,
           ...)
{
  type <- match.arg (type, c("point", "area"))
  # FIXME: check that it is either an integer or a character vector.
  if (length(intervals) == 1) {
    intervals <- seq_intervals_labels(
      round(seq(0,1 , length.out = 1 + intervals), 4), digits = 1)
  }
  if (is.function(col)) { # It is a color-map, like viridis()
    col <- col(length(intervals))
  } else {
    if (length(col) != 3) {
      stop ("'col' is either three colors (minimum, medium maximum) or a function that produces a colormap")
    }
    col <- colorRampPalette(col)(length(intervals))
  }
  # FIXME: The lowest color must be white (it should be the background).
  col[1] <- "white"
  title.left <- title.left
  title.right <- title.right

  maximise <- as.logical(maximise)
  if (length(maximise) == 1) {
    maximise <- rep_len(maximise, 2)
  } else if (length(maximise) != 2) {
    stop("length of maximise must be either 1 or 2")
  }

  data.left <- check_eaf_data(data.left)
  data.left[,1:2] <- matrix_maximise(data.left[,1:2, drop=FALSE], maximise)
  data.right <- check_eaf_data(data.right)
  data.right[,1:2] <- matrix_maximise(data.right[,1:2, drop=FALSE], maximise)

  attsurfs.left <- attsurfs.right <- list()
  if (!any(is.na(percentiles))) {
    attsurfs.left <- compute_eaf_as_list (data.left, percentiles)
    attsurfs.left <- lapply(attsurfs.left, matrix_maximise, maximise = maximise)
    attsurfs.right <- compute_eaf_as_list (data.right, percentiles)
    attsurfs.right <- lapply(attsurfs.right, matrix_maximise, maximise = maximise)
  }

  # FIXME: We do not need this for the full EAF.
  # Merge the data
  data.combined <- rbind_datasets(data.left, data.right)

  def.par <- par(no.readonly = TRUE) # save default, for resetting...
  on.exit(par(def.par))

  if (full.eaf) {
    if (type == "area") {
      lower.boundaries <- 0:(length(intervals)-1) * 100 / length(intervals)
      diff_left <- compute_eaf (data.left, percentiles = lower.boundaries)
      diff_right <- compute_eaf (data.right, percentiles = lower.boundaries)
    } else if (type == "point") {
      diff_left <- compute_eaf (data.left)
      diff_right <- compute_eaf (data.right)
      # Since plot_eafdiff_side uses floor to calculate the color, and
      # we want color[100] == color[99].
      diff_left[diff_left[,3] == 100, 3] <- 99
      diff_right[diff_right[,3] == 100, 3] <- 99
    }
    # Convert percentile into color index
    diff_left[,3] <- diff_left[,3] * length(intervals) / 100
    diff_right[,3] <- diff_right[,3] * length(intervals) / 100
    #remove(data.left,data.right,data.combined) # Free memory?
  } else {
    if (type == "area") {
      DIFF <- compute_eafdiff_polygon (data.combined, intervals = length(intervals))
    } else if (type == "point") {
      #remove(data.left,data.right) # Free memory?
      DIFF <- compute_eafdiff (data.combined, intervals = length(intervals))
      #remove(data.combined) # Free memory?
    }
    diff_left <- DIFF$left
    diff_right <- DIFF$right
  }
    
  # FIXME: This can be avoided and just taken from the full EAF.
  grand.attsurf <- compute_eaf_as_list (data.combined, c(0, 100))
  grand.best <- grand.attsurf[["0"]]
  grand.worst <- grand.attsurf[["100"]]

  xlim <- get_xylim(xlim, maximise[1],
                    data = c(grand.best[,1], grand.worst[,1],
                             range_finite(diff_left[,1]), range_finite(diff_right[,1])))
  ylim <- get_xylim(ylim, maximise[2],
                    data = c(grand.best[,2], grand.worst[,2],
                             range_finite(diff_left[,2]), range_finite(diff_right[,2])))

  grand.best <- matrix_maximise(grand.best, maximise)
  grand.worst <- matrix_maximise(grand.worst, maximise)
  diff_left[,1:2] <- matrix_maximise(diff_left[,1:2, drop=FALSE], maximise)
  diff_right[,1:2] <- matrix_maximise(diff_right[,1:2, drop=FALSE], maximise)
  
  # FIXME: This does not generate empty space between the two plots, but the
  # plots are not squared.
  layout(matrix(1:2, ncol=2, byrow=TRUE), respect=TRUE)
  bottommar <- 5
  topmar   <- 4
  leftmar  <- 4
  rightmar <- 4
  
  # FIXME: This generates empty spaces between the two plots. How to ensure
  # that the side-by-side plots are kept together?
  ## layout(matrix(1:2, ncol = 2))
  ## par (pty = 's') # Force it to be square
  ## bottommar <- 5
  ## topmar   <- 4
  ## leftmar  <- 4
  ## rightmar <- 4

  # cex.axis is multiplied by cex, but cex.lab is not.
  par(cex = cex, cex.lab = cex.lab, cex.axis = cex.axis
    , mar = c(bottommar, leftmar, topmar, 0)
    , lab = c(10,5,7)
    , las = 0
      )

  if (grand.lines) {
    attsurfs <- c(list(grand.best), attsurfs.left, list(grand.worst))
  } else {
    attsurfs <- attsurfs.left
  }
    
  plot_eafdiff_side (diff_left,
                     attsurfs = attsurfs,
                     col = col,
                     type = type, full.eaf = full.eaf,
                     title = title.left,
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

  if (grand.lines) {
    attsurfs <- c(list(grand.best), attsurfs.right, list(grand.worst))
  } else {
    attsurfs <- attsurfs.right
  }
  plot_eafdiff_side (diff_right,
                     attsurfs = attsurfs,
                     col = col,
                     type = type, full.eaf = full.eaf,
                     title = title.right,
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
  maximise <- as.logical(maximise)
  side <- match.arg (side, c("left", "right"))
  xaxis.side <- if (side == "left") "below" else "above"
  yaxis.side <- if (side == "left") "left" else "right"

  # For !full.eaf && type == "area", str(eafdiff) is a polygon:
  ##  $  num [, 1:2]
  ##    - attr(*, "col")= num []

  # Colors are correct for !full.eaf && type == "area"
  if (full.eaf || type == "point") {
    # FIXME: This is wrong, we should color (0.0, 1] with col[1], then (1, 2]
    # with col[1], etc, so that we never color the value 0.0 but we always
    # color the maximum value color without having to force it.
    
    # Why flooring and not ceiling? If a point has value 2.05, it should
    # be painted with color 2 rather than 3.
    # +1 because col[1] is white ([0,1)).
    eafdiff[,3L] <- floor(eafdiff[,3L]) + 1
    if (length(unique(eafdiff[,3L])) > length(col)) {
      stop ("Too few colors: length(unique(eafdiff[,3L])) > length(col)")
    }
  }

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
         plot_eaf_axis (xaxis.side, xlab, las = las, sci.notation = sci.notation)
         plot_eaf_axis (yaxis.side, ylab, las = las, sci.notation = sci.notation,
                        line = 2.2)
                         
         if (nrow(eafdiff)) {
           if (type == "area") {
             if (full.eaf) {
               plot_eaf_full_area(split.data.frame(eafdiff[,1:2], eafdiff[,3L]),
                                   extreme, maximise, col)
             } else {
               eafdiff[,1] <- rm_inf(eafdiff[,1], extreme[1])
               eafdiff[,2] <- rm_inf(eafdiff[,2], extreme[2])
               polycol <- attr(eafdiff, "col")
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
               polygon(eafdiff[,1], eafdiff[,2], border = col[polycol], col = col[polycol])
             }
           } else {
             ## The maximum value should also be painted.
             eafdiff[eafdiff[,3L] > length(col), 3L] <- length(col)
             eafdiff <- eafdiff[order(eafdiff[,3L], decreasing = FALSE), , drop=FALSE]
             points(eafdiff[,1], eafdiff[,2], col = col[eafdiff[,3L]], type = "p", pch=20)
           }
         }
       }), ...)

  lty <- c("solid", "dashed")
  lwd <- c(1)
  if (type == "area" && full.eaf) {
    col <- c("black", "black", "white")
  } else {
    col <- c("black")
  }

  plot_eaf_full_lines(attsurfs, extreme, maximise,
                      col = col, lty = lty, lwd = lwd)
  mtext(title, 1, line = 3.5, cex = par("cex.lab"), las = 0, font = 2)
  box()
}

