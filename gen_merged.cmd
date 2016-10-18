@echo off

set groupeddir=grouped
set mergeddir=merged

del /s /q %mergeddir%\*.csv

for %%i in (%groupeddir%/method1/*.csv) do (
    Rscript citibike_merge.R --in-file %groupeddir%/method1/%%i --out-file %mergeddir%/method1/%%i
)

for %%i in (%groupeddir%/method2/*.csv) do (
    Rscript citibike_merge.R --in-file %groupeddir%/method2/%%i --out-file %mergeddir%/method2/%%i
)
