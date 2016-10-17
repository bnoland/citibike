@echo off

set groupeddir=grouped
set statsdir=stats

set datayear=2016

del /s /q %statsdir%

for %%i in (%groupeddir%/method1/*) do (
    Rscript citibike_stats.R --in-file %groupeddir%/method1/%%i --out-file %statsdir%/method1/%%~ni.txt --data-year %datayear%
)

for %%i in (%groupeddir%/method2/*) do (
    Rscript citibike_stats.R --in-file %groupeddir%/method2/%%i --out-file %statsdir%/method2/%%~ni.txt --data-year %datayear%
)
