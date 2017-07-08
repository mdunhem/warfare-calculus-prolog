@echo off
REM Builds the Warfare Calculus Prolog app and makes an executable Windows batch file
if not exist "%cd%\bin" mkdir %cd%\bin

(
  echo @echo off
  echo call swipl -q -t main -s "%cd%/src/main.pl" %%*
) > %cd%\bin\warfare.bat
