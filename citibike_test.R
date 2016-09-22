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

"Usage: citibike_test.R (--out-file FILE) (--nobs N) (--nstations N) [--min-start-time TIME] [--max-start-time TIME] [--min-trip-duration D] [--max-trip-duration D] [--min-birth-year A] [--max-birth-year A] [--gender-probs PROBS] [--user-type-probs PROBS]

--help                      Show this.
--out-file FILE             Specify output file.
--nobs N                    Specify number of observations to generate.
--nstations N               Specify number of stations.
--min-start-time TIME       Specify minimum starting time.
--max-start-time TIME       Specify maximum starting time.
--min-trip-duration D       Specify minimum trip duration (in seconds).
--max-trip-duration D       Specify maximum trip duration (in seconds).
--min-birth-year A          Specify minimum birth year.
--max-birth-year A          Specify maximum birth year.
--gender-probs PROBS        Specify gender probabilities (unknown,male,female).
--user-type-probs PROBS     Specify user type probabilities (subscriber,customer).

The values for --min-start-time and --max-start-time are to be specified in the following R date/time
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

# TODO: Make sure that min.start <= max.start?

min.trip <- ifelse(is.null(options[["min-trip-duration"]]), 0, as.integer(options[["min-trip-duration"]]))
max.trip <- ifelse(is.null(options[["max-trip-duration"]]), 2000, as.integer(options[["max-trip-duration"]]))

# TODO: Make sure that min.trip <= max.trip?

min.birth <- ifelse(is.null(options[["min-birth-year"]]), 1940, as.integer(options[["min-birth-year"]]))
max.birth <- ifelse(is.null(options[["max-birth-year"]]), 2000, as.integer(options[["max-birth-year"]]))

# TODO: Make sure that min.birth <= max.birth?

if (!is.null(options[["gender-probs"]])) {
    gender.probs <- strsplit(options[["gender-probs"]], ",", fixed=TRUE)
    gender.probs <- unlist(gender.probs)
    gender.probs <- as.double(gender.probs)
    if (length(gender.probs) != 3)
        stop("Specify exactly 3 gender probabilities.")
} else {
    gender.probs = c(1/3, 1/3, 1/3)
}

# TODO: Make sure that gender probabilities add up to 1?

if (!is.null(options[["user-type-probs"]])) {
    user.type.probs <- strsplit(options[["user-type-probs"]], ",", fixed=TRUE)
    user.type.probs <- unlist(user.type.probs)
    user.type.probs <- as.double(user.type.probs)
    if (length(user.type.probs) != 2)
        stop("Specify exactly 2 user type probabilities.")
} else {
    user.type.probs <- c(1/2, 1/2)
}

# TODO: Make sure that user type probabilities add up to 1?

# Initialize the relevant attributes.

tripduration <- sample(min.trip:max.trip, size=nobs, replace=TRUE)
starttime <- TimeSample(min.start, max.start, nobs)
stoptime <- starttime + tripduration

# Make the times strings with the correct formatting.
starttime <- format(starttime, format=kTimeFormat)
stoptime <- format(stoptime, format=kTimeFormat)

start.station.id <- sample(1:nstations, size=nobs, replace=TRUE)
start.station.name <- NA
start.station.latitude <- NA
start.station.longitude <- NA

end.station.id <- sample(1:nstations, size=nobs, replace=TRUE)
end.station.name <- NA
end.station.latitude <- NA
end.station.longitude <- NA

bikeid <- NA

usertype <- sample(c("Subscriber", "Customer"), size=nobs, prob=user.type.probs, replace=TRUE)
birth.year <- sample(min.birth:max.birth, size=nobs, replace=TRUE)
gender <- sample(0:2, size=nobs, prob=gender.probs, replace=TRUE)

# Shove everything into a data frame.
citibike <- data.frame(tripduration,
                       starttime,
                       stoptime,
                       start.station.id,
                       start.station.name,
                       start.station.latitude,
                       start.station.longitude,
                       end.station.id,
                       end.station.name,
                       end.station.latitude,
                       end.station.longitude,
                       bikeid,
                       usertype,
                       birth.year,
                       gender)

# Write the data into the specified file.
write.csv(citibike, out.file, row.names=FALSE)
