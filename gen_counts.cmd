@echo off

set groupeddir=grouped
set countdir=counts

del /s /q %countdir%\*.csv

for %%i in (%groupeddir%/method1/*.csv) do (
    Rscript citibike_count.R --in-file %groupeddir%/method1/%%i --out-file %countdir%/method1/%%i
)

for %%i in (%groupeddir%/method2/*.csv) do (
    Rscript citibike_count.R --in-file %groupeddir%/method2/%%i --out-file %countdir%/method2/%%i
)
