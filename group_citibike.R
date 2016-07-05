# Citi Bike trip data processing script.
# TODO: This code could use a serious review. I'm sure a lot of this stuff could
# be done more efficiently, but I'm not experienced enough with R yet to know
# how to go about it.

library(docopt)

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

OutputGroup <- function(group, f) {
  # Outputs a single group to a CSV file.
  #
  # Args:
  #   group: The group to output.
  #   f: A connection to the file to output to.
  
  write.table(group, file=f, col.names=FALSE, append=TRUE,
              sep=",", dec=".", qmethod="double")
}

OutputGroupedData1 <- function(citibike, out.file, start.thresh, stop.thresh, show.progress) {
  # Groups the citibike data using method 1 (see README.md). Assumes that the
  # data are sorted as follows: first by start station ID, then by end station
  # ID, then by start time, and finally by stop time.
  #
  # Args:
  #   citibike: The data to be grouped.
  #   out.file: The file where the output will be stored.
  #   start.thresh: Used in defining the groups (see description in SameGroup).
  #   stop.thresh: Used in defining the groups (see description in SameGroup).
  #   show.progress: Set to TRUE if progress information should be outputted.
  
  f <- file(out.file, open="w")
  
  # Write out the column names.
  write.csv(citibike[0, ], file=f)
  
  group.id <- 1
  last.row.names <- NULL
  
  for (i in 1:nrow(citibike)) {
    ShowProgress(i, citibike, show.progress)
    
    x <- citibike[i, ]
    current.group <- x
    
    # Classify the observations before x.
    if (i > 1) {
      for (j in (i - 1):1) {
        y <- citibike[j, ]
        if (!SameGroup(x, y, start.thresh, stop.thresh))
          break
        current.group <- rbind(current.group, y)
      }
    }
    
    # Classify the observations after x.
    if (i < nrow(citibike)) {
      for (j in (i + 1):nrow(citibike)) {
        y <- citibike[j, ]
        if (!SameGroup(x, y, start.thresh, stop.thresh))
          break
        current.group <- rbind(current.group, y)
      }
    }
    
    # Ignore the current group if it's the same as the last group.
    current.row.names <- rownames(current.group)
    if (!is.null(last.row.names)
        && setequal(current.row.names, last.row.names)) {
      next
    }
    
    last.row.names <- current.row.names
    
    current.group$group.id <- group.id
    group.id <- group.id + 1
    
    current.group$group.member.id <- 1:nrow(current.group)
    
    OutputGroup(current.group, f)
  }
  
  close(f)
}

OutputGroupedData2 <- function(citibike, out.file, start.thresh, stop.thresh, show.progress) {
  # Groups the citibike data using method 2 (see README.md). Assumes that the
  # data are sorted as follows: first by start station ID, then by end station
  # ID, then by start time, and finally by stop time.
  #
  # Args:
  #   citibike: The data to be grouped.
  #   out.file: The file where the output will be stored.
  #   start.thresh: Used in defining the groups (see description in SameGroup).
  #   stop.thresh: Used in defining the groups (see description in SameGroup).
  #   show.progress: Set to TRUE if progress information should be outputted.
  
  f <- file(out.file, open="w")
  
  # Write out the column names.
  write.csv(citibike[0, ], file=f)
  
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
        
        current.group$group.member.id <- 1:nrow(current.group)
        
        OutputGroup(current.group, f)
        
        current.group <- y
      }
    }
  }
  
  current.group$group.id <- group.id
  current.group$group.member.id <- 1:nrow(current.group)
  
  OutputGroup(current.group, f)
  
  close(f)
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

# Process the command line arguments.

"Usage: group_citibike.R (--in-file FILE) (--out-file FILE) [--method METHOD] [--start-thresh START] [--stop-thresh STOP] [--nrows N] [--show-progress]

--help                Show this.
--in-file FILE        Specify input file.
--out-file FILE       Specify output file.
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

in.file       <- options[["in-file"]]
out.file      <- options[["out-file"]]
method        <- ifelse(is.null(options[["method"]]),      "1", options[["method"]])
start.thresh  <- ifelse(is.null(options[["start-thresh"]]), 60, as.integer(options[["start-thresh"]]))
stop.thresh   <- ifelse(is.null(options[["stop-thresh"]]),  60, as.integer(options[["stop-thresh"]]))
nrows         <- ifelse(is.null(options[["nrows"]]),        -1, as.integer(options[["nrows"]]))
show.progress <- options[["show-progress"]]

# Read in the data and place it in a data frame named citibike.

citibike <- read.csv(in.file, as.is=TRUE, nrows=nrows)

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

citibike$group.id <- NA         # Column for holding group IDs.
citibike$group.member.id <- NA  # Column for identifying members within groups.

# Divide the observations in citibike into groups and output the results to a
# file specified by out.file.

if (method == "1") {
  OutputGroupedData1(citibike, out.file, start.thresh, stop.thresh, show.progress)
} else if (method == "2") {
  OutputGroupedData2(citibike, out.file, start.thresh, stop.thresh, show.progress)
} else {
  stop("Invalid method number.")
}
