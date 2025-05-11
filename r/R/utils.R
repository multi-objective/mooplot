# Get correct xlim or ylim when maximising / minimising.
get_xylim <- function(lim, maximise, x)
{
  # FIXME: This seems too complicated.
  if (!is.null(lim) && maximise) lim <- -lim
  if (is.null(lim)) lim <- .range(x)
  if (maximise) lim <- .range(-lim)
  lim
}

get_extremes_ggplot <- function(maximise)
  c(if (maximise[1L]) -Inf else Inf, if (maximise[2L]) -Inf else Inf)

get_extremes <- function(xlim, ylim, maximise, log)
{
  if (length(log) && log != "")
    log <- strsplit(log, NULL)[[1L]]
  xlog <- "x" %in% log
  ylog <- "y" %in% log
  if (xlog) xlim <- log(xlim)
  if (ylog) ylim <- log(ylim)
  if (length(maximise) == 1L)
    maximise <- rep_len(maximise, 2L)
  dxlim <- 0.05 * diff(xlim)
  extreme1 <- if (maximise[1L]) xlim[1L] - dxlim else xlim[2L] + dxlim
  dylim <- 0.05 * diff(ylim)
  extreme2 <- if (maximise[2L]) ylim[1L] - dylim else ylim[2L] + dylim
  if (xlog) extreme1 <- exp(extreme1)
  if (ylog) extreme2 <- exp(extreme2)
  c(extreme1, extreme2)
}

add_extremes <- function(x, extremes, maximise)
{
  best1 <- if (maximise[1L]) max else min
  best2 <- if (maximise[2L]) max else min
  rbind(c(best1(x[,1L]), extremes[2L]), x, c(extremes[1L], best2(x[,2L])))
}

# FIXME: Accept ...
range_finite <- function(x)
{
  if (is.null(x)) return(NULL)
  x <- collapse::frange(x, finite=TRUE)
  if (anyNA(x)) return(NULL)
  x
}

## Calculate the intermediate points in order to plot a staircase-like
## polygon.
## Example: given ((1,2), (2,1)), it returns ((1,2), (2,2), (2,1)).
## Input should be already in the correct order.
points_steps <- function(x)
{
  n <- nrow(x)
  if (n == 1L) return(x)
  x <- rbind(x, cbind(x=x[-1L, 1L, drop=FALSE], y=x[-n, 2L, drop=FALSE]))
  idx <- c(as.vector(outer(c(0L, n), 1L:(n - 1L), "+")), n)
  stopifnot(length(idx) == nrow(x))
  stopifnot(!anyDuplicated(idx))
  x[idx, ]
}

nunique <- collapse::fnunique

has_file_extension <- function(filename, extension)
  grepl(paste0('[.]', extension, '$'), filename, ignore.case = TRUE)

starts_or_ends_with <- function(x, substr)
  startsWith(x, substr) | endsWith(x, substr)
