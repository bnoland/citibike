# citibike_test.R
#
# Generate randomized Citi Bike trip data for testing.

library(docopt)

TimeSample <- function(start.time, end.time, n) {
    # Returns a vector of times uniformly distributed between two given times.
    #
    # Args:
    #   start.time: The start time.
    #   end.time: The end time.
    #   n: The number of times to generate.
    #
    # Returns:
    #   A vector containing the times generated.
    
    dt <- as.numeric(difftime(end.time, start.time, unit="sec"))
    offsets <- runif(n, 0, dt)
    return(start.time + offsets)
}

# Process the command line arguments.

"Usage: citibike_test.R (--out-file FILE) (--nobs N) (--nstations N) [--min-start-time TIME] [--max-start-time TIME] [--min-trip-duration D] [--max-trip-duration D]

--help                  Show this.
--out-file FILE         Specify output file.
--nobs N                Specify number of observations to generate.
--nstations N           Specify number of stations.
--min-start-time TIME   Specify minimum starting time.
--max-start-time TIME   Specify maximum starting time.
--min-trip-duration D   Specify minimum trip duration (in seconds).
--max-trip-duration D   Specify maximum trip duration (in seconds).

The values for --time-beg and --time-end are to be specified in the following R date/time
format: \"%m/%d/%Y %H:%M:%S\" (e.g., \"9/1/2013 1:03:12\", \"12/24/2014 23:25:00\")." -> doc

options <- docopt(doc)

kTimeFormat <- "%m/%d/%Y %H:%M:%S"

out.file <- options[["out-file"]]
nobs <- as.integer(options[["nobs"]])
nstations <- as.integer(options[["nstations"]])

# TODO: For some reason the ifelse statement is vomiting a warning when I use it to process the time
# arguments. Look into this.

if (!is.null(options[["min-start-time"]])) {
    min.start <- strptime(options[["min-start-time"]], format=kTimeFormat)
} else {
    min.start <- strptime("01/01/2000 00:00:00", format=kTimeFormat)
}

if (!is.null(options[["max-start-time"]])) {
    max.start <- strptime(options[["max-start-time"]], format=kTimeFormat)
} else {
    max.start <- strptime("01/31/2000 23:59:59", format=kTimeFormat)
}

# TODO: Make sure min.start <= max.start?

min.trip <- ifelse(is.null(options[["min-trip-duration"]]), 0, as.integer(options[["min-trip-duration"]]))
max.trip <- ifelse(is.null(options[["max-trip-duration"]]), 0, as.integer(options[["max-trip-duration"]]))

# TODO: Make sure min.trip <= max.trip?

# Initialize the relevant attributes.

tripduration <- sample(min.trip:max.trip, size=nobs, replace=TRUE)
starttime <- TimeSample(min.start, max.start, nobs)
stoptime <- starttime + tripduration

# Make the times strings with the correct formatting.
starttime <- format(starttime, format=kTimeFormat)
stoptime <- format(stoptime, format=kTimeFormat)

start.station.id <- sample(1:nstations, size=nobs, replace=TRUE)
end.station.id <- sample(1:nstations, size=nobs, replace=TRUE)

# Shove everything into a data frame.
citibike <- data.frame(tripduration, starttime, stoptime, start.station.id, end.station.id)

# Write the data into the specified file.
write.csv(citibike, out.file, row.names=FALSE)
