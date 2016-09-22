# citibike_sample.R
#
# Extracts a random sample of a given size, with or without replacement, from a given Citi Bike trip
# data set.

library(docopt)

# Process the command line arguments.

"Usage: citibike_sample.R (--in-file FILE) (--out-file FILE) (--size N) [--nrows N] [--replace] [--row-names]

--help          Show this.
--in-file FILE  Specify input file.
--out-file FILE Specify output file.
--size N        Specify sample size.
--nrows N       Specify number of rows to read from the start of the data file.
--replace       Take samples with replacement; default is without replacement.
--row-names     Output row names." -> doc

options <- docopt(doc)

in.file   <- options[["in-file"]]
out.file  <- options[["out-file"]]
size      <- as.integer(options[["size"]])
nrows     <- ifelse(is.null(options[["nrows"]]), -1, as.integer(options[["nrows"]]))
replace   <- options[["replace"]]
clean     <- options[["clean"]]
row.names <- options[["row-names"]]

# Read in the data set.
citibike <- read.csv(in.file, as.is=TRUE, nrows=nrows)

if (!replace && size > nrow(citibike))
    stop("Cannot extract a sample larger than the data set when the sample is taken without replacement.")

# Extract a sample as specified.
samp <- citibike[sample(nrow(citibike), size, replace), ]

# Write the sample out to the specified file.
write.csv(samp, out.file, row.names=row.names)
