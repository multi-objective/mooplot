% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eafplot.R
\name{eafplot}
\alias{eafplot}
\alias{eafplot.default}
\alias{eafplot.list}
\title{Plot the Empirical Attainment Function for two objectives}
\usage{
eafplot(x, ...)

\method{eafplot}{default}(
  x,
  sets,
  groups = NULL,
  percentiles = c(0, 50, 100),
  attsurfs = NULL,
  maximise = c(FALSE, FALSE),
  type = "point",
  xlab = NULL,
  ylab = NULL,
  xlim = NULL,
  ylim = NULL,
  log = "",
  col = NULL,
  lty = c("dashed", "solid", "solid", "solid", "dashed"),
  lwd = 1.75,
  pch = NA,
  cex.pch = par("cex"),
  las = par("las"),
  legend.pos = paste0(ifelse(maximise[1L], "bottom", "top"), ifelse(rep_len(maximise,
    2L)[2L], "left", "right")),
  legend.txt = NULL,
  extra.points = NULL,
  extra.legend = NULL,
  extra.pch = 4:25,
  extra.lwd = 0.5,
  extra.lty = NA,
  extra.col = "black",
  xaxis.side = "below",
  yaxis.side = "left",
  axes = TRUE,
  sci.notation = FALSE,
  ...
)

\method{eafplot}{list}(x, ...)
}
\arguments{
\item{x}{Either a matrix of data values, or a data frame, or a list of
data frames of exactly three columns.}

\item{...}{Other graphical parameters to \code{\link[=plot.default]{plot.default()}}.}

\item{sets}{Vector indicating which set each point belongs to. Will be coerced to a factor.}

\item{groups}{This may be used to plot data for different algorithms on
the same plot. Will be coerced to a factor.}

\item{percentiles}{(\code{numeric()})\cr Vector indicating which percentile
should be plot. The default is to plot only the median attainment curve.}

\item{attsurfs}{TODO}

\item{maximise}{(\code{logical()}|\code{logical(1)})\cr Whether the objectives must be
maximised instead of minimised. Either a single logical value that applies
to all objectives or a vector of logical values, with one value per
objective.}

\item{type}{(\code{"point"}|\code{"area"})\cr Type of plot.}

\item{xlab, ylab, xlim, ylim, log, col, lty, lwd, pch, cex.pch, las}{Graphical
parameters, see \code{\link[=plot.default]{plot.default()}}.}

\item{legend.pos}{(\code{character(1)}|\code{list()}|\code{data.frame()})\cr Position of
the legend.  This may be xy coordinates or a keyword ("bottomright",
"bottom", "bottomleft", "left", "topleft", "top", "topright", "right",
"center"). See Details in \code{\link[=legend]{legend()}}.  A value of "none" hides the legend.}

\item{legend.txt}{(\code{expression()}|\code{character()})\cr Character or expression
vector to appear in the legend. If \code{NULL}, appropriate labels will be
generated.}

\item{extra.points}{A list of matrices or data.frames with
two-columns. Each element of the list defines a set of points, or
lines if one of the columns is \code{NA}.}

\item{extra.legend}{A character vector providing labels for the
groups of points.}

\item{extra.pch, extra.lwd, extra.lty, extra.col}{Control the graphical aspect
of the points. See \code{\link[=points]{points()}} and \code{\link[=lines]{lines()}}.}

\item{xaxis.side}{(\code{"below"}|\code{"above"})\cr On which side the x-axis is drawn.  See \code{\link[=axis]{axis()}}.}

\item{yaxis.side}{(\code{"left"}|\code{"right"})\cr On which side the y-axis is drawn. See \code{\link[=axis]{axis()}}.}

\item{axes}{(\code{logical(1)})\cr A logical value indicating whether both axes should be drawn
on the plot.}

\item{sci.notation}{(\code{logical(1)})\cr Generate prettier labels}
}
\value{
The attainment surfaces computed (invisibly).
}
\description{
Computes and plots the Empirical Attainment Function (EAF), either as
attainment surfaces for certain percentiles or as points.
}
\details{
This function can be used to plot random sets of points like those obtained
by different runs of biobjective stochastic optimisation algorithms
\citep{LopPaqStu09emaa}{moocore}.  An EAF curve represents the boundary
separating points that are known to be attainable (that is, dominated in
Pareto sense) in at least a fraction (quantile) of the runs from those that
are not \citep{Grunert01}{moocore}. The median EAF represents the curve
where the fraction of attainable points is 50\%.  In single objective
optimisation the function can be used to plot the profile of solution
quality over time of a collection of runs of a stochastic
optimizer \citep{LopVerDreDoe2025}{mooplot}.
}
\section{Methods (by class)}{
\itemize{
\item \code{eafplot(default)}: Main function

\item \code{eafplot(list)}: List interface for lists of data.frames or matrices

}}
\examples{
\donttest{
extdata_path <- system.file(package = "moocore", "extdata")
A1 <- read_datasets(file.path(extdata_path, "ALG_1_dat.xz"))
A2 <- read_datasets(file.path(extdata_path, "ALG_2_dat.xz"))
eafplot(A1, percentiles = 50, sci.notation = TRUE, cex.axis=0.6)
# The attainment surfaces are returned invisibly.
attsurfs <- eafplot(list(A1 = A1, A2 = A2), percentiles = 50)
str(attsurfs)

## Save as a PDF file.
# dev.copy2pdf(file = "eaf.pdf", onefile = TRUE, width = 5, height = 4)
}

## Using extra.points
\donttest{
data(HybridGA, package="moocore")
data(SPEA2relativeVanzyl, package="moocore")
eafplot(SPEA2relativeVanzyl, percentiles = c(25, 50, 75),
        xlab = expression(C[E]), ylab = "Total switches", xlim = c(320, 400),
        extra.points = HybridGA$vanzyl, extra.legend = "Hybrid GA")

data(SPEA2relativeRichmond, package="moocore")
eafplot (SPEA2relativeRichmond, percentiles = c(25, 50, 75),
         xlab = expression(C[E]), ylab = "Total switches",
         xlim = c(90, 140), ylim = c(0, 25),
         extra.points = HybridGA$richmond, extra.lty = "dashed",
         extra.legend = "Hybrid GA")

eafplot (SPEA2relativeRichmond, percentiles = c(25, 50, 75),
         xlab = expression(C[E]), ylab = "Total switches",
         xlim = c(90, 140), ylim = c(0, 25), type = "area",
         extra.points = HybridGA$richmond, extra.lty = "dashed",
         extra.legend = "Hybrid GA", legend.pos = "bottomright")

data(SPEA2minstoptimeRichmond, package="moocore")
SPEA2minstoptimeRichmond[,2] <- SPEA2minstoptimeRichmond[,2] / 60
eafplot (SPEA2minstoptimeRichmond, xlab = expression(C[E]),
         ylab = "Minimum idle time (minutes)", maximise = c(FALSE, TRUE),
         las = 1, log = "y", main = "SPEA2 (Richmond)",
         legend.pos = "bottomright")

data(tpls50x20_1_MWT, package="moocore")
eafplot(tpls50x20_1_MWT[, c(2,3)], sets = tpls50x20_1_MWT[,4L],
        groups = tpls50x20_1_MWT[["algorithm"]])
}
}
\references{
\insertAllCited{}
}
\seealso{
\code{\link[moocore:read_datasets]{moocore::read_datasets()}} \code{\link[=eafdiffplot]{eafdiffplot()}} \code{\link[=pdf_crop]{pdf_crop()}}
}
\concept{eaf}
