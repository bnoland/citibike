# Citi Bike trip data processing script.
# TODO: This code could use a serious review. I'm sure a lot of this stuff could
# be done more efficiently, but I'm not experienced enough with R yet to know
# how to go about it.
# TODO: Should this be a multipurpose script?

library(docopt)
library(data.table)

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
  
  if (x$start.station.id != y$start.station.id)
    return(FALSE)
  if (x$end.station.id != y$end.station.id)
    return(FALSE)
  
  diff <- as.numeric(difftime(x$starttime, y$starttime, units="secs"))
  if (abs(diff) > start.thresh)
    return(FALSE)
  
  diff <- as.numeric(difftime(x$stoptime, y$stoptime, units="secs"))
  if (abs(diff) > stop.thresh)
    return(FALSE)
  
  return(TRUE)
}

GroupDataMethod1 <- function(citibike, start.thresh, stop.thresh, show.progress) {
  # Groups the citibike data using method 1. Assumes that the data are sorted
  # as follows: first by start station ID, then by end station ID, then by start
  # time, and finally by stop time.
  #
  # Args:
  #   data: The data to be grouped.
  #   start.thresh: Used in defining the groups (see description in SameGroup).
  #   stop.thresh: Used in defining the groups (see description in SameGroup).
  #   show.progress: Set to TRUE if progress information should be outputted.
  #
  # Returns:
  #   A list of data frames representing the resulting groups.
  
  groups <- list()
  group.id <- 1
  
  for (i in 1:nrow(citibike)) {
    ShowProgress(i, citibike, show.progress)
    
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
    
    current.group$group.id <- group.id
    group.id <- group.id + 1
    
    groups[[length(groups) + 1]] <- current.group
  }
  
  return(groups)
}

GroupDataMethod2 <- function(citibike, start.thresh, stop.thresh, show.progress) {
  # Groups the citibike data using method 2. Assumes that the data are sorted
  # as follows: first by start station ID, then by end station ID, then by start
  # time, and finally by stop time.
  #
  # Args:
  #   data: The data to be grouped.
  #   start.thresh: Used in defining the groups (see description in SameGroup).
  #   stop.thresh: Used in defining the groups (see description in SameGroup).
  #   show.progress: Set to TRUE if progress information should be outputted.
  #
  # Returns:
  #   A list of data frames representing the resulting groups.
  
  groups <- list()
  group.id <- 1
  
  ShowProgress(1, citibike, show.progress)
  
  current.group <- citibike[1, ]
  
  if (nrow(citibike) > 1) {
    for (i in 2:nrow(citibike)) {
      ShowProgress(i, citibike, show.progress)
      
      x <- citibike[i - 1, ]
      y <- citibike[i, ]
      
      if (SameGroup(x, y, start.thresh, stop.thresh)) {
        current.group <- rbind(current.group, y)
      } else {
        # At the end of the current group.
        
        current.group$group.id <- group.id
        group.id <- group.id + 1
        
        groups[[length(groups) + 1]] <- current.group
        current.group <- y
      }
    }
  }
  
  current.group$group.id <- group.id
  groups[[length(groups) + 1]] <- current.group
  
  return(groups)
}

ShowProgress <- function(i, citibike, show.output=TRUE) {
  # Prints progress information (current observation number and percent
  # completion) to stderr.
  #
  # Args:
  #   i: Current observation number.
  #   citibike: The citibike data frame.
  #   show.output: If set to TRUE, progress information is outputted, otherwise
  #                nothing is displayed.
  
  if (!show.output)
    return()
  
  n <- nrow(citibike)
  percent <- (i / n) * 100
  
  cat("Processing observation ", i, " of ", n, " (", percent, "% complete)\n",
      sep="", file=stderr())
}

GetData <- function(data.file, nrows=-1, prepare=TRUE) {
  # Reads in the citibike data, and prepares it for processing if specified.
  #
  # Args:
  #   data.file: The file from which to read the data.
  #   nrows: The number of observations (rows) to read from the data file.
  #   prepare: Set to TRUE if the data should be prepared for processing.
  #
  # Returns:
  #   The (possibly prepared) data as a data frame object.
  
  # TODO: Maybe get rid of this function?
  
  citibike <- read.csv(data.file, as.is=TRUE, nrows=nrows)
  
  if (prepare) {
    # Convert the strings representing times in citibike to time objects.
    # TODO: Some data sets use different time formats -- handle this.
    
    kTimeFormat <- "%m/%d/%Y %H:%M:%S"

    citibike <- within(citibike, {
      starttime <- strptime(starttime, format=kTimeFormat)
      stoptime <- strptime(stoptime, format=kTimeFormat)
    })
    
    # Order citibike as follows: first by start station ID, then by end station
    # ID, then by start time, and finally by stop time.

    citibike <- with(citibike, citibike[order(start.station.id, end.station.id,
                                              starttime, stoptime), ])
    
    # Create a column for holding group IDs.
    
    citibike$group.id <- NULL
  }
  
  return(citibike)
}

FlattenGroups <- function(groups) {
  # Flatten a list of groups into a single data frame, labeling each entry with
  # a corresponding group ID.
  #
  # Args:
  #   groups: The groups to flatten.
  #
  # Returns:
  #   The flattened data in the form of a data frame.
  
  # data.table doesn't like the POSIXlt type, so convert all our times to
  # strings for now.
  # TODO: Apparently data.table has a replacement type called IDateTime. Maybe
  # use this instead?
  
  groups <- lapply(groups, function(group) {
    group$starttime <- as.character(group$starttime)
    group$stoptime <- as.character(group$stoptime)
    return(group)
  })
  
  flattened <- rbindlist(groups)
  
  return(flattened)
}

# Process the command line arguments.

"Usage: process_citibike.R (--data-file FILE) [--method METHOD] [--start-thresh START] [--stop-thresh STOP] [--nrows N] [--show-progress]

--help                Show this.
--data-file FILE      Specify data file.
--method METHOD       Specify grouping method to use.
--start-thresh START  Specify start time difference threshold.
--stop-thresh STOP    Specify stop time difference threshold.
--nrows N             Specify number of rows to read from the start of the data file.
--show-progress       Show progress." -> doc

options <- docopt(doc)

if (options[["help"]]) {
  cat(doc)
  quit()
}

# Extract the given values if present, and assign defaults otherwise.
# TODO: More stringent error checking?

data.file     <- options[["data-file"]]
method        <- ifelse(is.null(options[["method"]]),      "1", options[["method"]])
start.thresh  <- ifelse(is.null(options[["start-thresh"]]), 60, as.integer(options[["start-thresh"]]))
stop.thresh   <- ifelse(is.null(options[["stop-thresh"]]),  60, as.integer(options[["stop-thresh"]]))
nrows         <- ifelse(is.null(options[["nrows"]]),        -1, as.integer(options[["nrows"]]))
show.progress <- options[["show-progress"]]

# Read in the data and place it in a data frame named citibike.

citibike <- GetData(data.file, nrows)

# Divide the observations in citibike into groups.

groups <- switch(method,
            "1" = GroupDataMethod1(citibike, start.thresh, stop.thresh, show.progress),
            "2" = GroupDataMethod2(citibike, start.thresh, stop.thresh, show.progress),
            stop("Invalid method number.")
          )

# Flatten the groups into a single data set and write it to a CSV file on
# stdout.

write.csv(FlattenGroups(groups))

if (FALSE) {

# Testing.

for (g in groups) {
  print(g[c("start.station.id", "end.station.id", "starttime", "stoptime", "group.id")])
  print("")
}

}
