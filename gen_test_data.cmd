@echo off

set testdir=tests
set nobs=20

rem Tests for citibike_group.R

Rscript citibike_test.R --out-file %testdir%/test1.csv --nobs %nobs% --nstations 1 --min-trip-duration 0 --max-trip-duration 60
Rscript citibike_test.R --out-file %testdir%/test2.csv --nobs %nobs% --nstations 5 --min-trip-duration 0 --max-trip-duration 60
Rscript citibike_test.R --out-file %testdir%/test3.csv --nobs %nobs% --nstations 10 --min-trip-duration 0 --max-trip-duration 60

Rscript citibike_test.R --out-file %testdir%/test4.csv --nobs %nobs% --nstations 1 --min-trip-duration 0 --max-trip-duration 3600
Rscript citibike_test.R --out-file %testdir%/test5.csv --nobs %nobs% --nstations 5 --min-trip-duration 0 --max-trip-duration 3600
Rscript citibike_test.R --out-file %testdir%/test6.csv --nobs %nobs% --nstations 10 --min-trip-duration 0 --max-trip-duration 3600

Rscript citibike_test.R --out-file %testdir%/test7.csv --nobs %nobs% --nstations 1 --min-trip-duration 1800 --max-trip-duration 3600
Rscript citibike_test.R --out-file %testdir%/test8.csv --nobs %nobs% --nstations 5 --min-trip-duration 1800 --max-trip-duration 3600
Rscript citibike_test.R --out-file %testdir%/test9.csv --nobs %nobs% --nstations 10 --min-trip-duration 1800 --max-trip-duration 3600

rem Tests for citibike_stats.R

Rscript citibike_test.R --out-file %testdir%/test1.csv --nobs %nobs% --nstations 1 --min-trip-duration 0 --max-trip-duration 60
Rscript citibike_test.R --out-file %testdir%/test2.csv --nobs %nobs% --nstations 5 --min-trip-duration 0 --max-trip-duration 60
Rscript citibike_test.R --out-file %testdir%/test3.csv --nobs %nobs% --nstations 10 --min-trip-duration 0 --max-trip-duration 60
