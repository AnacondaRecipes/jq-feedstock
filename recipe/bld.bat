@echo off
setlocal EnableDelayedExpansion

copy "%RECIPE_DIR%\build_win.sh" .
if errorlevel 1 exit /b 1

FOR /F "delims=" %%i IN ('cygpath.exe -u "%PREFIX%"') DO set "PREFIX=%%i/Library/ucrt64"
set SRC_DIR=%SRC_DIR:\=/%

set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1

bash -lc "bash build_win.sh"
if errorlevel 1 exit /b 1
exit /b 0
