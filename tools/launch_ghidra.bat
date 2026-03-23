@echo off
set JAVA_HOME=C:\Users\danpo\Desktop\rvs\tools\..\tools\jdk
set PATH=%JAVA_HOME%\bin;%PATH%
cd /d "%~dp0..\tools\ghidra"
start ghidraRun.bat %*
