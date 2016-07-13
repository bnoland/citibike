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

# Calculate gender and user type proportions for each group size.

gender.props <- NULL
user.type.props <- NULL

for (n in 1:max(citibike$groupsize)) {
  total <- sum(citibike$groupsize == n)
  
  # Calculate user type proportions.
  
  nsubscriber <- sum(citibike$groupsize == n & citibike$usertype == "Subscriber")
  ncustomer   <- total - nsubscriber
  
  entry <- data.frame(total, subscriber=nsubscriber / total,
                             customer=ncustomer / total)
  
  user.type.props <- rbind(user.type.props, entry)
  
  # Calculate gender proportions.
  
  nmale     <- sum(citibike$groupsize == n & citibike$gender == 1)
  nfemale   <- sum(citibike$groupsize == n & citibike$gender == 2)
  nunknown  <- total - nmale - nfemale
  
  entry <- data.frame(total, unknown=nunknown / total,
                             male=nmale / total,
                             female=nfemale / total)
  
  gender.props <- rbind(gender.props, entry)
}

gender.props
user.type.props

if (FALSE) {

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

#write.csv(citibike)
}
