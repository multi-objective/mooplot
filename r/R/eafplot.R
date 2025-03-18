#' Plot the Empirical Attainment Function for two objectives
#'
#' Computes and plots the Empirical Attainment Function, either as
#' attainment surfaces for certain percentiles or as points.
#'
#' This function can be used to plot random sets of points like those obtained
#' by different runs of biobjective stochastic optimisation algorithms \citep{LopPaqStu09emaa}.  An EAF
#' curve represents the boundary separating points that are known to be
#' attainable (that is, dominated in Pareto sense) in at least a fraction
#' (quantile) of the runs from those that are not \citep{Grunert01}. The median EAF represents
#' the curve where the fraction of attainable points is 50%.  In single
#' objective optimisation the function can be used to plot the profile of
#' solution quality over time of a collection of runs of a stochastic optimizer. \citep{LopVerDreDoe2025}.
#'
#' @param x Either a matrix of data values, or a data frame, or a list of
#'     data frames of exactly three columns.
#'
#' @export
eafplot <- function(x, ...) UseMethod("eafplot")

#' @describeIn eafplot Main function
#'
#' @param sets Vector indicating which set each point belongs to. Will be coerced to a factor.
#'
#' @param groups This may be used to plot data for different algorithms on
#'   the same plot. Will be coerced to a factor.
#'
#' @param percentiles (`numeric()`)\cr Vector indicating which percentile
#'   should be plot. The default is to plot only the median attainment curve.
#'
#' @param attsurfs TODO
#'
#' @param type (`"point"`|`"area"`)\cr Type of plot.
#'
#' @param xlab,ylab,xlim,ylim,log,col,lty,lwd,pch,cex.pch,las Graphical
#'   parameters, see [plot.default()].
#'
#' @param legend.pos (`character(1)`|`list()`|`data.frame()`)\cr Position of
#'   the legend.  This may be xy coordinates or a keyword ("bottomright",
#'   "bottom", "bottomleft", "left", "topleft", "top", "topright", "right",
#'   "center"). See Details in [legend()].  A value of "none" hides the legend.
#'
#' @param legend.txt (`expression()`|`character()`)\cr Character or expression
#'   vector to appear in the legend. If `NULL`, appropriate labels will be
#'   generated.
#'
#' @param extra.points A list of matrices or data.frames with
#'   two-columns. Each element of the list defines a set of points, or
#'   lines if one of the columns is `NA`.
#'
#' @param extra.pch,extra.lwd,extra.lty,extra.col Control the graphical aspect
#'   of the points. See [points()] and [lines()].
#'
#' @param extra.legend A character vector providing labels for the
#'   groups of points.
#'
#' @param maximise (`logical()`|`logical(1)`)\cr Whether the objectives must be
#'   maximised instead of minimised. Either a single logical value that applies
#'   to all objectives or a vector of logical values, with one value per
#'   objective.
#'
#' @param xaxis.side (`"below"`|`"above"`)\cr On which side the x-axis is drawn.  See [axis()].
#'
#' @param yaxis.side (`"left"`|`"right"`)\cr On which side the y-axis is drawn. See [axis()].
#'
#' @param axes (`logical(1)`)\cr A logical value indicating whether both axes should be drawn
#'   on the plot.
#'
#' @param sci.notation Generate prettier labels
#'
#' @param ... Other graphical parameters to [plot.default()].
#'
#' @return  The attainment surfaces computed (invisibly).
#'
#' @seealso   [moocore::read_datasets()] [eafdiffplot()] [pdf_crop()]
#'
#'@examples
#' \donttest{
#' extdata_path <- system.file(package = "moocore", "extdata")
#' A1 <- read_datasets(file.path(extdata_path, "ALG_1_dat.xz"))
#' A2 <- read_datasets(file.path(extdata_path, "ALG_2_dat.xz"))
#' eafplot(A1, percentiles = 50, sci.notation = TRUE, cex.axis=0.6)
#' # The attainment surfaces are returned invisibly.
#' attsurfs <- eafplot(list(A1 = A1, A2 = A2), percentiles = 50)
#' str(attsurfs)
#'
#' ## Save as a PDF file.
#' # dev.copy2pdf(file = "eaf.pdf", onefile = TRUE, width = 5, height = 4)
#' }
#'
#' ## Using extra.points
#' \donttest{
#' data(HybridGA, package="moocore")
#' data(SPEA2relativeVanzyl, package="moocore")
#' eafplot(SPEA2relativeVanzyl, percentiles = c(25, 50, 75),
#'         xlab = expression(C[E]), ylab = "Total switches", xlim = c(320, 400),
#'         extra.points = HybridGA$vanzyl, extra.legend = "Hybrid GA")
#'
#' data(SPEA2relativeRichmond, package="moocore")
#' eafplot (SPEA2relativeRichmond, percentiles = c(25, 50, 75),
#'          xlab = expression(C[E]), ylab = "Total switches",
#'          xlim = c(90, 140), ylim = c(0, 25),
#'          extra.points = HybridGA$richmond, extra.lty = "dashed",
#'          extra.legend = "Hybrid GA")
#'
#' eafplot (SPEA2relativeRichmond, percentiles = c(25, 50, 75),
#'          xlab = expression(C[E]), ylab = "Total switches",
#'          xlim = c(90, 140), ylim = c(0, 25), type = "area",
#'          extra.points = HybridGA$richmond, extra.lty = "dashed",
#'          extra.legend = "Hybrid GA", legend.pos = "bottomright")
#'
#' data(SPEA2minstoptimeRichmond, package="moocore")
#' SPEA2minstoptimeRichmond[,2] <- SPEA2minstoptimeRichmond[,2] / 60
#' eafplot (SPEA2minstoptimeRichmond, xlab = expression(C[E]),
#'          ylab = "Minimum idle time (minutes)", maximise = c(FALSE, TRUE),
#'          las = 1, log = "y", main = "SPEA2 (Richmond)",
#'          legend.pos = "bottomright")
#'
#' data(tpls50x20_1_MWT, package="moocore")
#' eafplot(tpls50x20_1_MWT[, c(2,3)], sets = tpls50x20_1_MWT[,4L],
#'         groups = tpls50x20_1_MWT[["algorithm"]])
#' }
#' @references
#' \insertAllCited{}
#' @concept eaf
#' @export
eafplot.default <-
  function (x, sets, groups = NULL,
            percentiles = c(0,50,100),
            attsurfs = NULL,
            maximise = c(FALSE, FALSE),
            type = "point",
            xlab = NULL, ylab = NULL,
            xlim = NULL, ylim = NULL,
            log = "",
            col = NULL,
            lty = c("dashed", "solid", "solid", "solid", "dashed"),
            lwd = 1.75,
            pch = NA,
            # FIXME: this allows partial matching if cex is passed, so passing cex has not effect.
            cex.pch = par("cex"),
            las = par("las"),
            legend.pos = paste0(ifelse(maximise[1L], "bottom", "top"),
              ifelse(rep_len(maximise, 2L)[2L], "left", "right")),
            legend.txt = NULL,
            # FIXME: Can we get rid of the extra. stuff? Replace it with calling points after eafplot.default in examples and eafplot.pl.
            extra.points = NULL, extra.legend = NULL,
            extra.pch = 4:25,
            extra.lwd = 0.5,
            extra.lty = NA,
            extra.col = "black",
            xaxis.side = "below", yaxis.side = "left",
            axes = TRUE,
            sci.notation = FALSE,
            ... )
{
  type <- match.arg(type, c("point", "area"))
  xaxis_side <- match.arg(xaxis.side, c("below", "above"))
  yaxis_side <- match.arg(yaxis.side, c("left", "right"))
  maximise <- as.logical(maximise)
  if (missing(sets)) {
    sets <- x[, ncol(x)]
    x <- x[, -ncol(x), drop=FALSE]
  }

  if (is.null(col)) {
    if (type == "point") {
      col <- c("black", "darkgrey", "black", "grey40", "darkgrey")
    } else {
      col <- c("grey", "black")
    }
  }

  if (is.null(xlab))
    xlab <- if (!is.null(colnames(x)[1L])) colnames(x)[1L] else "objective 1"
  if (is.null(ylab))
    ylab <- if (!is.null(colnames(x)[2L])) colnames(x)[2L] else "objective 2"

  if (is.null (attsurfs)) {
    attsurfs <- eaf(x, sets, percentiles = percentiles, maximise = maximise, groups = groups)
    attsurfs <- eaf_as_list(attsurfs)
    #    attsurfs <- lapply(attsurfs, matrix_maximise, maximise = maximise)
  } else {
    # Don't we need to apply maximise?
    attsurfs <- lapply(attsurfs, function(x) as.matrix(x[, c(1L,2L), drop=FALSE]))
  }

  # FIXME: We should take the range from the attsurfs to not make x mandatory.
  if (is.null(xlim))
    xlim <- range_finite(x[, 1L])
  if (is.null(ylim))
    ylim <- range_finite(x[, 2L])

  maximise <- rep_len(maximise, 2L)
  extreme <- get_extremes(xlim, ylim, maximise, log)

  # FIXME: Find a better way to handle different x-y scale.
  yscale <- 1
  ## if (ymaximise) {
  ##   #yscale <- 60
  ##   yreverse <- -1
  ##   attsurfs <- lapply (attsurfs, function (x)
  ##                       { x[,2] <- yreverse * x[,2] / yscale; x })
  ##   ylim <- yreverse * ylim / yscale
  ##   extreme[2] <- yreverse * extreme[2]
  ##   if (log == "y") extreme[2] <- 1
  ## }

  ## lab' A numerical vector of the form 'c(x, y, len)' which modifies
  ##     the default way that axes are annotated.  The values of 'x'
  ##     and 'y' give the (approximate) number of tickmarks on the x
  ##     and y axes and 'len' specifies the label length.  The default
  ##     is 'c(5, 5, 7)'.  Note that this only affects the way the
  ##     parameters 'xaxp' and 'yaxp' are set when the user coordinate
  ##     system is set up, and is not consulted when axes are drawn.
  ##     'len' _is unimplemented_ in R.
  args <- list(...)
  args <- args[names(args) %in% c("cex", "cex.lab", "cex.axis", "lab")]
  par_default <- list(cex = 1.0, cex.lab = 1.1, cex.axis = 1.0, lab = c(10,5,7))
  par_default <- modifyList(par_default, args)
  withr::local_par(par_default)

  plot(xlim, ylim, type = "n", xlab = "", ylab = "",
       xlim = xlim, ylim = ylim, log = log, axes = FALSE, las = las,
       panel.first = ({
         if (axes) {
           plot_eaf_axis(xaxis_side, xlab, las = las, sci.notation = sci.notation)
           plot_eaf_axis(yaxis_side, ylab, las = las, sci.notation = sci.notation,
                         # FIXME: eafplot uses 2.2, why the difference?
                         line = 2.75)
         }

         # FIXME: Perhaps have a function plot.eaf.lines that computes
         # several percentiles for a single algorithm and then calls
         # points() or polygon() as appropriate to add attainment
         # surfaces to an existing plot. This way we can factor out
         # the code below and use it in plot.eaf and plot.eafdiff
         if (type == "area") {
           # FIXME (Proposition): allow the user to provide the palette colors?
           if (length(col) == 2) {
             colfunc <- colorRampPalette(col)
             col <- colfunc(length(attsurfs))
           } else if (length(col) != length(attsurfs)) {
             stop ("length(col) != 2, but with 'type=area', eafplot.default needs just two colors")
           }
           plot_eaf_full_area(attsurfs, extreme, maximise, col = col)
         } else {
           ## Recycle values
           lwd <- rep_len(lwd, length(attsurfs))
           lty <- rep_len(lty, length(attsurfs))
           col <- rep_len(col, length(attsurfs))
           if (!is.null(pch)) pch <- rep_len(pch, length(attsurfs))
           plot_eaf_full_lines(attsurfs, extreme, maximise,
                               col = col, lty = lty, lwd = lwd, pch = pch, cex = cex.pch)
         }
       }), ...)


  if (!is.null (extra.points)) {
    if (!is.list (extra.points[[1]])) {
      extra.name <- deparse(substitute(extra.points))
      extra.points <- list(extra.points)
      names(extra.points) <- extra.name
    }
    ## Recycle values
    extra.length <- length(extra.points)
    extra.lwd <- rep_len(extra.lwd, extra.length)
    extra.lty <- rep_len(extra.lty, extra.length)
    extra.col <- rep_len(extra.col, extra.length)
    extra.pch <- rep_len(extra.pch, extra.length)
    if (is.null(extra.legend)) {
      extra.legend <- names(extra.points)
      if (is.null(extra.legend))
        extra.legend <- paste0("extra.points ", seq_along(extra.points))
    }
    for (i in seq_along(extra.points)) {
      if (any(is.na(extra.points[[i]][,1L]))) {
        if (is.na(extra.lty[i])) extra.lty <- "dashed"
        ## Extra points are given in the correct order so no reverse
        extra.points[[i]][,2L] <- extra.points[[i]][,2L] / yscale
        abline(h=extra.points[[i]][,2L], lwd = extra.lwd[i], col = extra.col[i],
          lty = extra.lty[i])
        extra.pch[i] <- NA

      } else if (any(is.na(extra.points[[i]][,2L]))) {
        if (is.na(extra.lty[i])) extra.lty <- "dashed"
        abline(v=extra.points[[i]][,1L], lwd = extra.lwd[i], col = extra.col[i],
               lty = extra.lty[i])
        extra.pch[i] <- NA

      } else {
        ## Extra points are given in the correct order so no reverse
        extra.points[[i]][,2L] <- extra.points[[i]][,2L] / yscale
        if (!is.na(extra.pch[i]))
          points (extra.points[[i]], type = "p", pch = extra.pch[i],
                  col = extra.col[i], cex = cex.pch)
        if (!is.na(extra.lty[i]))
          points (extra.points[[i]], type = "s", lty = extra.lty[i],
                  col = extra.col[i], lwd = extra.lwd[i])
      }
      lwd <- c(lwd, extra.lwd[i])
      lty <- c(lty, extra.lty[i])
      col <- c(col, extra.col[i])
      pch <- c(pch, extra.pch[i])
      if (is.null(extra.legend[i])) extra.legend[i]
    }
  }

  # Setup legend.
  if (is.null(legend.txt) && !is.null(percentiles)) {
    legend.txt <- paste0(percentiles, "%")
    legend.txt <- sub("^0%$", "best", legend.txt)
    legend.txt <- sub("^50%$", "median", legend.txt)
    legend.txt <- sub("^100%$", "worst", legend.txt)

    if (!is.null(groups)) {
      groups <- factor(groups)
      legend.txt <- as.vector(t(outer(levels(groups), legend.txt, paste)))
    }
  }
  legend.txt <- c(legend.txt, extra.legend)

  if (!is.null(legend.txt) && is.na(pmatch(legend.pos,"none"))) {
    if (type == "area") {
      legend(x = legend.pos, y = NULL,
             legend = legend.txt, fill = c(col, "#FFFFFF"),
             bg="white",bty="n", xjust=0, yjust=0, cex=0.9)
    } else {
      legend(legend.pos,
             legend = legend.txt, xjust=1, yjust=1, bty="n",
             lty = lty,  lwd = lwd, pch = pch, col = col, merge=T)
    }
  }

  box()
  invisible(attsurfs)
}

prettySciNotation <- function(x, digits = 1L)
{
  if (length(x) > 1L) {
    return(append(prettySciNotation(x[1L]), prettySciNotation(x[-1L])))
  }
  if (!x) return(0)
  exponent <- floor(log10(x))
  base <- round(x / 10^exponent, digits)
  as.expression(substitute(base %*% 10^exponent,
                           list(base = base, exponent = exponent)))
}

axis_side <- function(side)
{
  if (!is.character(side)) return(side)
  switch (side,
    below = 1L,
    left  = 2L,
    above = 3L,
    right = 4L,
    stop("Unknown side '", side, "'"))
}

plot_eaf_axis <- function(side, lab, las,
                          col = 'lightgray', lty = 'dotted', lwd = par("lwd"),
                          line = 2.1, sci.notation = FALSE)
{
  side <- axis_side(side)
  ## FIXME: Do we still need lwd=0.5, lty="26" to work-around for R bug?
  at <- axTicks(if (side %% 2 == 0) 2 else 1)
  labels <- if (sci.notation) prettySciNotation(at) else formatC(at, format = "g")
  ## if (log == "y") {
  ##   ## Custom log axis (like gnuplot but in R is hard)
  ##   max.pow <- 6
  ##   at <- c(1, 5, 10, 50, 100, 500, 1000, 1500, 10^c(4:max.pow))
  ##   labels <- c(1, 5, 10, 50, 100, 500, 1000, 1500,
  ##               parse(text = paste("10^", 4:max.pow, sep = "")))

  ##   #at <- c(60, 120, 180, 240, 300, 480, 600, 900, 1200, 1440)
  ##   #labels <- formatC(at,format="g")

  ##   ## Now do the minor ticks, at 1/10 of each power of 10 interval
  ##   ##at.minor <- 2:9 * rep(c(10^c(1:max.pow)) / 10, each = length(2:9))
  ##   at.minor <- 1:10 * rep(c(10^c(1:max.pow)) / 10, each = length(1:10))
  ##   axis (yaxis_side, at = at.minor, tcl = -0.25, labels = FALSE, las=las)
  ##   axis (yaxis_side, at = at.minor, labels = FALSE, tck=1,
  ##         col='lightgray', lty='dotted', lwd=par("lwd"))
  ## }

  ## tck=1 draws the horizontal grid lines (grid() is seriously broken).
  axis(side, at=at, labels=FALSE, tck = 1,
       col='lightgray', lty = 'dotted', lwd = par("lwd"))
  axis(side, at=at, labels=labels, las = las)
  mtext(lab, side, line = line, cex = par("cex") * par("cex.axis"),
        las = 0)
}

plot_eaf_full_lines <- function(attsurfs, extreme, maximise,
                                col, lty, lwd, pch = NULL, cex = par("cex"))
{
  ## Recycle values
  lwd <- rep_len(lwd, length(attsurfs))
  lty <- rep_len(lty, length(attsurfs))
  col <- rep_len(col, length(attsurfs))
  if (!is.null(pch))
    pch <- rep_len(pch, length(attsurfs))

  attsurfs <- lapply(attsurfs, add_extremes, extreme, maximise)
  for (k in seq_along(attsurfs)) {
    # FIXME: Is there a way to plot points and steps in one call?
    if (!is.null(pch))
      points(attsurfs[[k]], type = "p", col = col[k], pch = pch[k], cex = cex)
    points(attsurfs[[k]], type = "s", col = col[k], lty = lty[k], lwd = lwd[k])
  }
}

plot_eaf_full_area <- function(attsurfs, extreme, maximise, col)
{
  stopifnot(length(attsurfs) == length(col))
  for (i in seq_along(attsurfs)) {
    poli <- add_extremes(points_steps(attsurfs[[i]]), extreme, maximise)
    poli <- rbind(poli, extreme)
    polygon(poli[,1L], poli[,2L], border = NA, col = col[i])
  }
}

# Create labels:
# seq_intervals_labels(seq(0,1, length.out=5), digits = 1)
# "[0.0, 0.2)" "[0.2, 0.4)" "[0.4, 0.6)" "[0.6, 0.8)" "[0.8, 1.0]"
# FIXME: Add examples and tests
seq_intervals_labels <- function(s, first_open = FALSE, last_open = FALSE,
                                 digits = NULL)
{
  # FIXME:  This should use:
  # levels(cut(0, s, dig.lab=digits, include.lowest=TRUE, right=FALSE))
  s <- formatC(s, digits = digits, format = if (is.null(digits)) "g" else "f")
  if (length(s) < 2) stop ("sequence must have at least 2 values")
  intervals <- paste0("[", s[-length(s)], ", ", s[-1], ")")
  if (first_open)
    substr(intervals[1], 0, 1) <- "("
  if (!last_open) {
    len <- nchar(intervals[length(intervals)])
    substr(intervals[length(intervals)], len, len+1) <- "]"
  }
  intervals
}


#' @describeIn eafplot List interface for lists of data.frames or matrices
#' @export
eafplot.list <- function(x, ...)
{
  if (!is.list(x))
    stop("'x' must be a list of data.frames or matrices with exactly three columns")

  sets <- lapply(x, function(y) {
    if (length(dim(y)) != 2L)
      stop("Each element of the list must be a data.frame or a matrix.")
    if (ncol(y) != 3L)
      stop("Each element of the list must have exactly three columns.")
    y[,3L]
  })
  groups <- if (is.null(names(x))) seq_along(x) else names(x)
  groups <- rep(groups, times = sapply(x, nrow))
  # FIXME: Is this the fastest way? Maybe rbind first, then drop the column?
  x <- lapply(x, function(y) y[,-3L, drop=FALSE])

  eafplot(do.call(rbind,x),
          sets = unlist(sets, recursive=FALSE, use.names=FALSE),
          groups = groups, ...)
}
