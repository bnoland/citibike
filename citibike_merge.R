# citibike_merge.R

library(docopt)

"Usage: citibike_merge.R (--in-file FILE) (--out-file FILE)

--help              Show this.
--in-file FILE      Specify file to merge with data.
--out-file FILE     Specify output file." -> doc

options <- docopt(doc)

in.file <- options[["in-file"]]
out.file <- options[["out-file"]]

citibike <- read.csv(in.file, as.is=TRUE)

merge.data.dir <- "merge_data"

data1 <- read.csv(file.path(merge.data.dir, "data1.csv"), as.is=TRUE)
data2 <- read.csv(file.path(merge.data.dir, "data2.csv"), as.is=TRUE)
data3 <- read.csv(file.path(merge.data.dir, "data3.csv"), as.is=TRUE)

merged <- merge(data1, data2, by.x="D_station", by.y="Name")
merged <- merge(merged, data3, by="D_station")
merged <- merge(citibike, merged, by.x="start.station.name", by.y="D_station")

merged$gender[merged$gender == 0] <- NA
merged$male <- as.integer(merged$gender == 2)

merged$customer <- as.integer(merged$usertype == "Customer")

# Capitalized for consistency with Subwaydummy...
merged$Bikepathdummy <- as.integer(merged$bikepath != "")

write.csv(merged, out.file)
