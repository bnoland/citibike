library(docopt)

"Usage: citibike_count.R (--in-file FILE) (--out-file FILE)

--help              Show this.
--in-file FILE      Specify input file.
--out-file FILE     Specify output file." -> doc

options <- docopt(doc)

in.file <- options[["in-file"]]
out.file <- options[["out-file"]]

citibike <- read.csv(in.file, as.is=TRUE)

station.data <- unique(citibike[c("start.station.name",
                                "start.station.latitude",
                                "start.station.longitude")])

station.name <- station.data$start.station.name
station.lat <- station.data$start.station.latitude
station.long <- station.data$start.station.longitude

results <- data.frame(station.name=character(),
                      location=character(),
                      size1=integer(),
                      size2=integer(),
                      size3=integer(),
                      size4=integer(),
                      size5plus=integer(), stringsAsFactors=FALSE)

# TODO: This is probably the dumb way to do this...
for (i in 1:nrow(station.data)) {
    name <- station.name[i]
    lat <- station.lat[i]
    long <- station.long[i]
    
    location <- paste(lat, long, sep=",")
    
    relevant <- citibike[citibike$start.station.name == name, ]
    counts <- integer(5)
    
    for (i in 1:4)
        counts[i] <- sum(relevant$group.size == i) / i
    
    max.group.size <- max(relevant$group.size)
    counts[5] <- 0
    for (i in 5:max.group.size)
        counts[5] = counts[5] + sum(relevant$group.size == i) / i
    
    row <- data.frame(station.name=name,
                      location=location,
                      size1=counts[1],
                      size2=counts[2],
                      size3=counts[3],
                      size4=counts[4],
                      size5plus=counts[5],
                      total=sum(counts), stringsAsFactors=FALSE)
    
    results <- rbind(results, row)
}

write.csv(results, out.file)
