# citibike_regress.R

library(docopt)

"Usage: citibike_regress.R (--in-file FILE) (--out-file FILE)

--help              Show this.
--in-file FILE      Specify input file.
--out-file FILE     Specify output file." -> doc

options <- docopt(doc)

in.file <- options[["in-file"]]
out.file <- options[["out-file"]]

citibike <- read.csv(in.file, as.is=TRUE)

sink(out.file)

with(citibike, {
    fit <- lm(tripduration ~ group.size + LU23 + male + Subwaydummy + Bikepathdummy, data=citibike)
    print(summary(fit))
    
    fit <- lm(tripduration ~ group.size + LU23 + customer + Subwaydummy + Bikepathdummy, data=citibike)
    print(summary(fit))
    
    fit <- lm(tripduration ~ group.size + LU458 + male + Subwaydummy + Bikepathdummy, data=citibike)
    print(summary(fit))
    
    fit <- lm(tripduration ~ group.size + LU458 + customer + Subwaydummy + Bikepathdummy, data=citibike)
    print(summary(fit))
    
    fit <- lm(tripduration ~ group.size + LU6710 + male + Subwaydummy + Bikepathdummy, data=citibike)
    print(summary(fit))
    
    fit <- lm(tripduration ~ group.size + LU6710 + customer + Subwaydummy + Bikepathdummy, data=citibike)
    print(summary(fit))
})
