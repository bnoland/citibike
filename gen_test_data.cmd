@echo off

set datadir=tests/data

set nobs=20

rem Note: As expected, having a smaller number of stations available tends to increase the average
rem group size.

Rscript citibike_test.R --out-file %datadir%/test1.csv --nobs %nobs% --nstations 1 --min-trip-duration 0 --max-trip-duration 0
Rscript citibike_test.R --out-file %datadir%/test2.csv --nobs %nobs% --nstations 5 --min-trip-duration 0 --max-trip-duration 0

Rscript citibike_test.R --out-file %datadir%/test3.csv --nobs %nobs% --nstations 1 --min-trip-duration 0 --max-trip-duration 3600
Rscript citibike_test.R --out-file %datadir%/test4.csv --nobs %nobs% --nstations 5 --min-trip-duration 0 --max-trip-duration 3600

Rscript citibike_test.R --out-file %datadir%/test5.csv --nobs %nobs% --nstations 1 --min-trip-duration 3600 --max-trip-duration 3600
Rscript citibike_test.R --out-file %datadir%/test6.csv --nobs %nobs% --nstations 5 --min-trip-duration 3600 --max-trip-duration 3600

Rscript citibike_test.R --out-file %datadir%/test7.csv --nobs %nobs% --nstations 1 --min-birth-year 2000 --max-birth-year 2000
Rscript citibike_test.R --out-file %datadir%/test8.csv --nobs %nobs% --nstations 5 --min-birth-year 2000 --max-birth-year 2000

Rscript citibike_test.R --out-file %datadir%/test9.csv --nobs %nobs% --nstations 1 --min-birth-year 1950 --max-birth-year 2000
Rscript citibike_test.R --out-file %datadir%/test10.csv --nobs %nobs% --nstations 5 --min-birth-year 1950 --max-birth-year 2000

Rscript citibike_test.R --out-file %datadir%/test11.csv --nobs %nobs% --nstations 1 --min-birth-year 1950 --max-birth-year 1950
Rscript citibike_test.R --out-file %datadir%/test12.csv --nobs %nobs% --nstations 5 --min-birth-year 1950 --max-birth-year 1950

Rscript citibike_test.R --out-file %datadir%/test13.csv --nobs %nobs% --nstations 1 --gender-probs 0,0,1
Rscript citibike_test.R --out-file %datadir%/test14.csv --nobs %nobs% --nstations 5 --gender-probs 0,0,1

Rscript citibike_test.R --out-file %datadir%/test15.csv --nobs %nobs% --nstations 1 --gender-probs 0,1,0
Rscript citibike_test.R --out-file %datadir%/test16.csv --nobs %nobs% --nstations 5 --gender-probs 0,1,0

Rscript citibike_test.R --out-file %datadir%/test17.csv --nobs %nobs% --nstations 1 --gender-probs 1,0,0
Rscript citibike_test.R --out-file %datadir%/test18.csv --nobs %nobs% --nstations 5 --gender-probs 1,0,0

Rscript citibike_test.R --out-file %datadir%/test19.csv --nobs %nobs% --nstations 1 --user-type-probs 0,1
Rscript citibike_test.R --out-file %datadir%/test20.csv --nobs %nobs% --nstations 5 --user-type-probs 0,1

Rscript citibike_test.R --out-file %datadir%/test21.csv --nobs %nobs% --nstations 1 --user-type-probs 1,0
Rscript citibike_test.R --out-file %datadir%/test22.csv --nobs %nobs% --nstations 5 --user-type-probs 1,0
