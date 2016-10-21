@echo off

set mergeddir=merged
set regdir=regressions

del /s /q %regdir%\*.txt

for %%i in (%mergeddir%/method1/*.csv) do (
    Rscript citibike_regress.R --in-file %mergeddir%/method1/%%i --out-file %regdir%/method1/%%~ni.txt
)

for %%i in (%mergeddir%/method2/*.csv) do (
    Rscript citibike_regress.R --in-file %mergeddir%/method2/%%i --out-file %regdir%/method2/%%~ni.txt
)
