@echo off
REM ==========================================================================
REM run_headless.bat - Convenience wrapper for run_headless.ps1
REM ==========================================================================
REM Usage:
REM   tools\run_headless.bat
REM   tools\run_headless.bat -GhidraHome "C:\Ghidra\ghidra_11.3"
REM   tools\run_headless.bat -BinaryFilter "Core.dll"
REM ==========================================================================

powershell.exe -ExecutionPolicy Bypass -File "%~dp0run_headless.ps1" %*
