@echo off
setlocal enabledelayedexpansion

copy "%SRC_DIR%\jq-win64.exe" "%LIBRARY_BIN%\jq.exe"
if errorlevel 1 exit 1