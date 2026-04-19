@echo off
REM Refresh the dashboard from model.xlsx

setlocal
cd /d "%~dp0"

set "INPUT=%~1"
if "%INPUT%"=="" set "INPUT=model.xlsx"

if not exist "%INPUT%" (
  echo ERROR: '%INPUT%' not found in %cd%
  echo Usage: refresh.bat [path-to-excel-file]
  exit /b 1
)

echo ==^> Extracting data from %INPUT%
python extract_data.py "%INPUT%" data.json
if errorlevel 1 exit /b 1

echo ==^> Building dashboard
python build_dashboard.py dashboard_template.html data.json dashboard.html
if errorlevel 1 exit /b 1

echo.
echo Done. Open dashboard.html in your browser.
