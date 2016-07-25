# citibike_stats.R
#
# Outputs summary statistics about potential groups of riders (as determined by citibike_group.R)
# in Citi Bike trip data.

library(docopt)

Round <- function(df, ndigits) {
    # Rounds the numeric entries of a data frame to a specified number of decimal
    # places.
    #
    # Args:
    #   df: The data frame whose entries are to be rounded.
    #   ndigits: The number of decimal places.
    #
    # Returns:
    #   The data frame with the numeric entries rounded.
    
    num.cols <- sapply(df, is.numeric)
    df[num.cols] <- lapply(df[num.cols], round, ndigits)
    return(df)
}

# Process the command line arguments.

"Usage: citibike_stats.R (--in-file FILE) (--out-file FILE) (--data-year YEAR) [--ndigits N]

--help              Show this.
--in-file FILE      Specify input file.
--out-file FILE     Specify output file.
--data-year YEAR    Specify year this data was collected.
--ndigits N         Specify number of decimal places to show in output." -> doc

options <- docopt(doc)

if (options[["help"]]) {
    cat(doc)
    quit()
}

in.file   <- options[["in-file"]]
out.file  <- options[["out-file"]]
data.year <- as.integer(options[["data-year"]])
ndigits   <- ifelse(is.null(options[["ndigits"]]), 3, as.integer(options[["ndigits"]]))

# Read in the data and place it in a data frame. Ignore the first 13 columns;
# read in the remaining 6.
col.classes <- c(rep("NULL", 13), rep(NA, 6))
citibike <- read.csv(in.file, as.is=TRUE, colClasses=col.classes)

# Make a column containing (approximate) ages.
citibike$age <- data.year - citibike$birthyear

# Make a copy of the data in wide format for convenience.
# TODO: Is there a simple way that avoids the reshape?
reshaped <- reshape(citibike, idvar="groupid", timevar="groupmemberid",
                                        v.names=c("usertype", "birthyear", "gender", "age"),
                                        direction="wide")

# Calculate counts for each gender type (unknown=0, male=1, female=2).

gender.col.names <- grep("\\bgender\\.[[:digit:]]+", names(reshaped))
gender.cols <- reshaped[, gender.col.names]

reshaped$nunknown <- apply(gender.cols, 1, function(x) length(which(x == 0)))
reshaped$nmales <- apply(gender.cols, 1, function(x) length(which(x == 1)))
reshaped$nfemales <- apply(gender.cols, 1, function(x) length(which(x == 2)))

# Calculate counts for each user type.

user.type.col.names <- grep("\\busertype\\.[[:digit:]]+", names(reshaped))
user.type.cols <- reshaped[, user.type.col.names]

reshaped$nsubscribers <- apply(user.type.cols, 1, function(x) {
    length(which(x == "Subscriber"))
})
reshaped$ncustomers <- apply(user.type.cols, 1, function(x) {
    length(which(x == "Customer"))
})

# Calculate the age difference between the oldest person and youngest person for
# each group.

age.col.names <- grep("\\bage\\.[[:digit:]]+", names(reshaped))
age.cols <- reshaped[, age.col.names]

reshaped$agediff <- apply(age.cols, 1, function(x) {
    if (all(is.na(x)))
        return(NA)
    
    result <- diff(range(x, na.rm=TRUE))
    return(result)
})

# Calculate gender proportions, user type proportions, and age statistics for
# each group size.

gender.props <- NULL
user.type.props <- NULL
age.stats <- NULL

max.group.size <- max(citibike$groupsize)

for (n in 1:max.group.size) {
    relevant <- citibike[citibike$groupsize == n, ]
    total <- nrow(relevant)
    
    # Calculate user type proportions.
    
    nsubscriber <- sum(relevant$usertype == "Subscriber")
    ncustomer <- total - nsubscriber
    
    entry <- data.frame(groupsize=n, total, subscriber=nsubscriber / total,
                                            customer=ncustomer / total)
    
    user.type.props <- rbind(user.type.props, entry)
    
    # Calculate gender proportions.
    
    nmale <- sum(relevant$gender == 1)
    nfemale <- sum(relevant$gender == 2)
    nunknown <- total - nmale - nfemale
    
    entry <- data.frame(groupsize=n, total, unknown=nunknown / total, male=nmale / total,
                        female=nfemale / total)
    
    gender.props <- rbind(gender.props, entry)
    
    # Calculate age statistics.
    
    meanage <- mean(relevant$age, na.rm=TRUE)
    sdage <- sd(relevant$age, na.rm=TRUE)
    
    # Need wide data for next few calculations.
    relevant <- reshaped[reshaped$groupsize == n, ]
    
    meandiff <- mean(relevant$agediff, na.rm=TRUE)
    sddiff <- sd(relevant$agediff, na.rm=TRUE)
    
    entry <- data.frame(groupsize=n, meanage, sdage, meandiff, sddiff)
    age.stats <- rbind(age.stats, entry)
}

sink(out.file)  # Redirect standard output to the output file.

cat("Gender proportions:\n\n")
print(Round(gender.props, ndigits))

cat("\nUser type proportions:\n\n")
print(Round(user.type.props, ndigits))

cat("\nAge statistics:\n\n")
print(Round(age.stats, ndigits))

# Calculate proportions for each possible group gender composition and user
# type composition.

for (n in 1:max.group.size) {
    relevant <- reshaped[reshaped$groupsize == n, ]
    total <- nrow(relevant)
    
    gender.props <- NULL
    user.type.props <- NULL
    
    for (k in 0:n) {
        # Calculate gender composition.
        
        # Count of groups with k males and (n-k) females.
        count <- sum(relevant$nmales == k & relevant$nfemales == n-k)
        
        entry <- data.frame(nmales=k, nfemales=n-k, count, prop=count / total)
        gender.props <- rbind(gender.props, entry)
        
        # Calculate user type composition.
        
        # Count of groups with k subscribers and (n-k) customers.
        count <- sum(relevant$nsubscribers == k & relevant$ncustomers == n-k)
        
        entry <- data.frame(nsubscribers=k, ncustomers=n-k, count, prop=count / total)
        user.type.props <- rbind(user.type.props, entry)
    }
    
    cat("\nGender composition (group size = ", n, "):\n\n", sep="")
    print(Round(gender.props, ndigits))
    
    cat("\nUser type composition (group size = ", n, "):\n\n", sep="")
    print(Round(user.type.props, ndigits))
}
