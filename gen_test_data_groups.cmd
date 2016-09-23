@echo off

set testdir=tests
set ntests=9

set startthresh=1800
set stopthresh=1800

for /l %%i in (1,1,%ntests%) do (
    Rscript citibike_group.R --in-file %testdir%/test%%i.csv --out-file %testdir%/test%%i_method_1.csv --method 1 --start-thresh %startthresh% --stop-thresh %stopthresh%
    Rscript citibike_group.R --in-file %testdir%/test%%i.csv --out-file %testdir%/test%%i_method_2.csv --method 2 --start-thresh %startthresh% --stop-thresh %stopthresh%
)
