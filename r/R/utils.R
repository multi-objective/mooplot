# Get correct xlim or ylim when maximising / minimising.
get_xylim <- function(lim, maximise, data)
{
  # FIXME: This seems too complicated.
  if (!is.null(lim) && maximise) lim <- -lim 
  if (is.null(lim)) lim <- range(data)
  if (maximise) lim <- range(-lim)
  lim
}
  
get_extremes <- function(xlim, ylim, maximise, log)
{
  if (length(log) && log != "")
    log <- strsplit(log, NULL)[[1L]]
  if ("x" %in% log) xlim <- log(xlim)
  if ("y" %in% log) ylim <- log(ylim)
  
  extreme1 <- ifelse(maximise[1],
                     xlim[1] - 0.05 * diff(xlim),
                     xlim[2] + 0.05 * diff(xlim))
  extreme2 <- ifelse(maximise[2],
                     ylim[1] - 0.05 * diff(ylim),
                     ylim[2] + 0.05 * diff(ylim))
  
  if ("x" %in% log) extreme1 <- exp(extreme1)
  if ("y" %in% log) extreme2 <- exp(extreme2)
  c(extreme1, extreme2)
}

add_extremes <- function(x, extremes, maximise)
{
  best1 <- if (maximise[1]) max else min
  best2 <- if (maximise[2]) max else min
  rbind(c(best1(x[,1]), extremes[2]), x, c(extremes[1], best2(x[,2])))
}

rm_inf <- function(x, xmax)
{
  x[is.infinite(x)] <- xmax
  x
}


# FIXME: Accept ...
max_finite <- function (x)
{
  x <- as.vector(x)
  x <- x[is.finite(x)]
  if (length(x)) return(max(x))
  NULL
}

# FIXME: Accept ...
min_finite <- function (x)
{
  x <- as.vector(x)
  x <- x[is.finite(x)]
  if (length(x)) return(min(x))
  NULL
}

# FIXME: Accept ...
range_finite <- function(x)
{
  x <- as.vector(x)
  x <- x[is.finite(x)]
  if (length(x)) return(range(x))
  NULL
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
