@echo off

set groupeddir=grouped
set statsdir=stats

set datayear=2016

del /s /q %statsdir%\*.txt

for %%i in (%groupeddir%/method1/*.csv) do (
    Rscript citibike_stats.R --in-file %groupeddir%/method1/%%i --out-file %statsdir%/method1/%%~ni.txt --data-year %datayear%
)

for %%i in (%groupeddir%/method2/*.csv) do (
    Rscript citibike_stats.R --in-file %groupeddir%/method2/%%i --out-file %statsdir%/method2/%%~ni.txt --data-year %datayear%
)
