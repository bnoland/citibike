# citibike_test.R
#
# Generate randomized Citi Bike trip data for testing.

library(docopt)

# Process the command line arguments.

"Usage: citibike_test.R (--nobs N) (--nstations N) [--time-beg TIME] [--time-end TIME] [--trip-dur-mean M] [--trip-dur-sd S] [--granularity G]

--help              Show this.
--nobs N            Specify the number of observations to generate.
--nstations N       Specify the number of stations.
--time-beg TIME     Specify the beginning of the start time range.
--time-end TIME     Specify the end of the start time range.
--granularity G     Specify the minimum time between the start times of any two observations (e.g., \"1 secs\").
--trip-dur-mean M   Specify trip duration mean.
--trip-dur-sd S     Specify trip duration standard deviation

Values for the trip duration are assumed to be normally distributed with given mean and
standard deviation.

The values for --time-beg and --time-end are to be specified in the following R date/time
format: \"%m/%d/%Y %H:%M:%S\" (e.g., \"9/1/2013 1:03:12\", \"12/24/2014 23:25:00\")." -> doc

options <- docopt(doc)

kTimeFormat <- "%m/%d/%Y %H:%M:%S"

nobs <- as.integer(options[["nobs"]])
nstations <- as.integer(options[["nstations"]])

time.beg <- strptime("1/1/2000 00:00:00", format=kTimeFormat)
if (!is.null(options[["time-beg"]]))
    time.beg <- strptime(options[["time-beg"]], format=kTimeFormat)

time.end <- strptime("1/31/2000 23:59:59", format=kTimeFormat)
if (!is.null(options[["time-end"]]))
    time.end <- strptime(options[["time-end"]], format=kTimeFormat)

#granularity <- ifelse(is.null(options[["granularity"]]), "1 secs", options[["granularity"]])

# Default values for mean and stddev based on values from 6/2016 data.
trip.dur.mean <- ifelse(is.null(options[["trip-dur-mean"]]), 1000, as.integer(options[["trip-dur-mean"]]))
trip.dur.sd <- ifelse(is.null(options[["trip-dur-sd"]]), 7000, as.integer(options[["trip-dur-sd"]]))

print(time.beg)
print(time.end)

print(trip.dur.mean)
print(trip.dur.sd)
