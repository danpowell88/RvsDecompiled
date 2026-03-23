@echo off
REM Headless Ghidra analysis for Ravenshield decompilation project
REM Usage: run_headless.bat <command> [args...]
REM Example: run_headless.bat -import ..\retail\system\Core.dll -postScript ..\ghidra\scripts\batch_import.py

set JAVA_HOME=C:\Users\danpo\Desktop\rvs\tools\..\tools\jdk
set PATH=%JAVA_HOME%\bin;%PATH%
set PROJECT_DIR=%~dp0..\ghidra\project
set PROJECT_NAME=RavenShield

cd /d "%~dp0..\tools\ghidra"
call support\analyzeHeadless.bat "%PROJECT_DIR%" "%PROJECT_NAME%" %*
