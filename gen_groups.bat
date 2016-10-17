@echo off

set datadir=data
set groupeddir=grouped

del /s /q %groupeddir%\*.csv

for %%i in (%datadir%/*.csv) do (
    Rscript citibike_group.R --in-file %datadir%/%%i --out-file %groupeddir%/method1/%%i --method 1 --show-progress
    Rscript citibike_group.R --in-file %datadir%/%%i --out-file %groupeddir%/method2/%%i --method 2 --show-progress
)
