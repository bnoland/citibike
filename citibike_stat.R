library(docopt)

# Process the command line arguments.

"Usage: citibike_stat.R (--in-file FILE)

--help                Show this.
--in-file FILE        Specify input file." -> doc

options <- docopt(doc)

if (options[["help"]]) {
  cat(doc)
  quit()
}

in.file <- options[["in-file"]]

# Read in the data and place it in a data frame. Ignore the first 13 columns;
# read in the remaining 6.
col.classes <- c(rep("NULL", 13), rep(NA, 6))
citibike <- read.csv(in.file, as.is=TRUE, colClasses=col.classes)

# Subscriber indicator.
citibike$subscriber <- citibike$usertype == "Subscriber"

# Place the data in a wide format for convenience.
citibike <- reshape(citibike, idvar="groupid", timevar="groupmemberid",
                    v.names=c("usertype", "birthyear", "gender", "subscriber"),
                    direction="wide")

# Calculate counts for each gender type (unknown=0, male=1, female=2).

gender.col.names <- grep("\\bgender\\.[[:digit:]]+", names(citibike))
gender.cols <- citibike[, gender.col.names]

citibike$nunknown <- apply(gender.cols, 1, function(x) length(which(x == 0)))
citibike$nmales   <- apply(gender.cols, 1, function(x) length(which(x == 1)))
citibike$nfemales <- apply(gender.cols, 1, function(x) length(which(x == 2)))

write.csv(citibike)
