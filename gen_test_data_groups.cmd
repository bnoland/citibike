@echo off

set datadir=tests/data
set groupeddir=tests/grouped

set startthresh=1800
set stopthresh=1800

for %%i in (%datadir%/*) do (
    Rscript citibike_group.R --in-file %datadir%/%%i --out-file %groupeddir%/method1/%%i --method 1 --start-thresh %startthresh% --stop-thresh %stopthresh%
    Rscript citibike_group.R --in-file %datadir%/%%i --out-file %groupeddir%/method2/%%i --method 2 --start-thresh %startthresh% --stop-thresh %stopthresh%
)
