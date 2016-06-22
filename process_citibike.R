
SameGroup <- function(x, y, start.thresh, stop.thresh) {
  # Are two observations in the same group?
  #
  # Args:
  #   x: The first observation.
  #   y: The second observation.
  #   start.thresh: If the start time for x and the start time for y differ by
  #                 more than start.thresh, then they are not in the same group.
  #   stop.thresh: If the stop time for x and the stop time for y differ by
  #                more than stop.thresh, then they are not in the same group.
  #
  # Returns:
  #   TRUE if x and y are in the same group, FALSE otherwise.
  
  if (x[, "start.station.id"] != y[, "start.station.id"])
    return(FALSE)
  if (x[, "end.station.id"] != y[, "end.station.id"])
    return(FALSE)
  
  diff <- as.numeric(difftime(x[, "starttime"], y[, "starttime"], units="secs"))
  if (abs(diff) > start.thresh)
    return(FALSE)
  
  diff <- as.numeric(difftime(x[, "stoptime"], y[, "stoptime"], units="secs"))
  if (abs(diff) > stop.thresh)
    return(FALSE)
  
  return(TRUE)
}

GroupDataMethod1 <- function(citibike, start.thresh, stop.thresh) {
  # Groups the citibike data using method 1. Assumes that the data are sorted
  # as follows: first by start station ID, then by end station ID, then by start
  # time, and finally by stop time.
  #
  # Args:
  #   data: The data to be grouped.
  #   start.thresh: Used in defining the groups (see description in SameGroup).
  #   stop.thresh: Used in defining the groups (see description in SameGroup).
  #
  # Returns:
  #   A list of data frames representing the resulting groups.
  
  groups <- list()
  
  for (i in 1:nrow(citibike)) {
    x <- citibike[i, ]
    current.group <- NULL
    
    # Classify the observations before x.
    if (i > 1) {
      for (j in (i - 1):1) {
        y <- citibike[j, ]
        if (!SameGroup(x, y, start.thresh, stop.thresh))
          break
        current.group <- rbind(current.group, y)
      }
    }
    
    current.group <- rbind(current.group, x)
    
    # Classify the observations after x.
    if (i < nrow(citibike)) {
      for (j in (i + 1):nrow(citibike)) {
        y <- citibike[j, ]
        if (!SameGroup(x, y, start.thresh, stop.thresh))
          break
        current.group <- rbind(current.group, y)
      }
    }
    
    groups[[length(groups) + 1]] <- current.group
  }
  
  return(groups)
}

GroupDataMethod2 <- function(citibike, start.thresh, stop.thresh) {
  # Groups the citibike data using method 2. Assumes that the data are sorted
  # as follows: first by start station ID, then by end station ID, then by start
  # time, and finally by stop time.
  #
  # Args:
  #   data: The data to be grouped.
  #   start.thresh: Used in defining the groups (see description in SameGroup).
  #   stop.thresh: Used in defining the groups (see description in SameGroup).
  #
  # Returns:
  #   A list of data frames representing the resulting groups.
  
  groups <- list()
  current.group <- citibike[1, ]

  for (i in 2:nrow(citibike)) {
    x <- citibike[i - 1, ]
    y <- citibike[i, ]
    
    if (SameGroup(x, y, start.thresh, stop.thresh)) {
      current.group <- rbind(current.group, y)
    } else {
      groups[[length(groups) + 1]] <- current.group
      current.group <- y
    }
  }

  groups[[length(groups) + 1]] <- current.group
  
  return(groups)
}

GetData <- function(data.file, nrows=-1, prepare=TRUE) {
  # Reads in the citibike data, and prepares it for processing if specified.
  #
  # Args:
  #   data.file: The file from which to read the data.
  #   nrows: The number of observations (rows) to read from the data file.
  #   prepare: Set to TRUE iff the data should be prepared for processing.
  #
  # Returns:
  #   The (possibly prepared) data as a data frame object.
  
  citibike <- read.csv(data.file, stringsAsFactors=FALSE, nrows=nrows)
  
  if (prepare) {
    # Convert the strings representing times in citibike to time objects.

    kTimeFormat <- "%d/%m/%Y %H:%M:%S"

    citibike <- within(citibike, {
      starttime <- strptime(starttime, format=kTimeFormat)
      stoptime <- strptime(stoptime, format=kTimeFormat)
    })

    # Order citibike as follows: first by start station ID, then by end station
    # ID, then by start time, and finally by stop time.

    citibike <- with(citibike, citibike[order(start.station.id, end.station.id,
                                              starttime, stoptime), ])
  }
  
  return(citibike)
}

# Process the command line arguments.

args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 1)
  stop("Usage: Rscript process_citibike.R method data.file start.thresh stop.thresh nrows")

# Extract the given values if present, and assign defaults otherwise.

data.file    <- args[1]
method       <- ifelse(length(args) < 2, 1,  args[2])
start.thresh <- ifelse(length(args) < 3, 60, as.integer(args[3]))
stop.thresh  <- ifelse(length(args) < 4, 60, as.integer(args[4]))
nrows        <- ifelse(length(args) < 5, -1, as.integer(args[5]))

# Read in the data and place it in a data frame named citibike.

citibike <- GetData(data.file, nrows)

# Divide the observations in citibike into groups.

groups <- switch(method,
            "1" = GroupDataMethod1(citibike, start.thresh, stop.thresh),
            "2" = GroupDataMethod2(citibike, start.thresh, stop.thresh)
          )

# Testing.

for (g in groups) {
  print(g[c("start.station.id", "end.station.id", "starttime", "stoptime")])
  print("")
}
