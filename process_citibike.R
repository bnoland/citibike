
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

# Read in the data and place it in a data frame named citibike.

kDataFile <- "201507-citibike-tripdata.csv"
citibike <- read.csv(kDataFile, stringsAsFactors=FALSE, nrows=500)

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

# Start and stop time difference thresholds for use with SameGroup.
kStartThresh <- 60
kStopThresh <- 60

# Divide the observations in citibike into groups defined by SameGroup.
# TODO: There's a potential issue with this grouping algorithm that I only
# realized after writing the damned thing.

groups <- list()
current.group <- citibike[1, ]

for (i in 2:nrow(citibike)) {
  x <- citibike[i - 1, ]
  y <- citibike[i, ]
  
  if (SameGroup(x, y, kStartThresh, kStopThresh)) {
    current.group <- rbind(current.group, y)
  } else {
    groups[[length(groups) + 1]] <- current.group
    current.group <- y
  }
}

groups[[length(groups) + 1]] <- current.group

# Testing.

for (g in groups) {
  print(g[c("start.station.id", "end.station.id", "starttime", "stoptime")])
  print("")
}

#citibike[c("start.station.id", "end.station.id", "starttime", "stoptime")]
