@echo off
REM =============================================================================
REM configure-msvc71.bat  —  Configure and (optionally) build with MSVC 7.1
REM =============================================================================
REM Usage:
REM   configure-msvc71.bat          Configure only (creates/updates build-71\)
REM   configure-msvc71.bat build     Configure + build Release
REM   configure-msvc71.bat rebuild   Clean + reconfigure + build Release
REM =============================================================================

setlocal enabledelayedexpansion

REM --- Resolve project root (directory this batch file lives in) ---
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

REM --- Toolchain paths ---
set "MSVC71=%ROOT%\tools\toolchain\msvc71\bin"
set "VS2019_X86=C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x86"
set "WINSDK_LIB=%ROOT%\tools\toolchain\winsdk\Lib"
set "MSVC71_LIB=%ROOT%\tools\toolchain\msvc71\lib"
set "DXSDK_LIB=%ROOT%\tools\toolchain\dxsdk\Lib"

REM --- Validate MSVC 7.1 compiler exists ---
if not exist "%MSVC71%\cl.exe" (
    echo ERROR: MSVC 7.1 cl.exe not found at %MSVC71%
    echo        Check that tools\toolchain\msvc71\bin\cl.exe is present.
    exit /b 1
)

REM --- Validate VS 2019 nmake / lib ---
if not exist "%VS2019_X86%\nmake.exe" (
    echo ERROR: VS2019 nmake.exe not found at %VS2019_X86%
    echo        Install Visual Studio 2019 Build Tools with C++ components.
    exit /b 1
)

REM --- Set PATH: MSVC 7.1 bin first (for c1.dll, c2.dll, mspdb71.dll),
REM              then VS2019 x86 bin (for nmake.exe, lib.exe),
REM              then Windows Kits x86 bin (for rc.exe) ---
set "WINKITS_BIN=C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x86"
if not exist "%WINKITS_BIN%\rc.exe" (
    REM Try finding any Windows Kits rc.exe
    for /d %%V in ("C:\Program Files (x86)\Windows Kits\10\bin\*") do (
        if exist "%%V\x86\rc.exe" set "WINKITS_BIN=%%V\x86"
    )
)
set "PATH=%MSVC71%;%VS2019_X86%;%WINKITS_BIN%;%PATH%"

REM --- Set LIB: linker library search paths ---
set "LIB=%MSVC71_LIB%;%WINSDK_LIB%;%DXSDK_LIB%"

REM --- Locate cmake.exe ---
set "CMAKE_EXE="
for %%P in (cmake.exe) do set "CMAKE_EXE=%%~$PATH:P"
if not defined CMAKE_EXE (
    REM Try common install locations
    for %%C in (
        "C:\Program Files\CMake\bin\cmake.exe"
        "C:\Program Files (x86)\CMake\bin\cmake.exe"
        "%VS2019_X86%\..\..\..\..\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
    ) do (
        if exist %%C set "CMAKE_EXE=%%~C"
    )
)
if not defined CMAKE_EXE (
    echo ERROR: cmake.exe not found. Install CMake 3.10+ and add it to PATH.
    exit /b 1
)
echo Using CMake: %CMAKE_EXE%

REM --- Handle rebuild (clean) ---
if /i "%1"=="rebuild" (
    echo Cleaning build-71\ ...
    if exist "%ROOT%\build-71" rmdir /s /q "%ROOT%\build-71"
)

REM --- Configure ---
echo.
echo Configuring with MSVC 7.1 toolchain...
echo   Compiler : %MSVC71%\cl.exe
echo   NMake    : %VS2019_X86%\nmake.exe
echo   lib.exe  : %VS2019_X86%\lib.exe
echo   Output   : %ROOT%\build-71\
echo.

if not exist "%ROOT%\build-71" mkdir "%ROOT%\build-71"

"%CMAKE_EXE%" ^
    -B "%ROOT%\build-71" ^
    -G "NMake Makefiles" ^
    -DCMAKE_TOOLCHAIN_FILE="%ROOT%\cmake\msvc71.cmake" ^
    -DCMAKE_BUILD_TYPE=Release ^
    "%ROOT%"

if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed.
    exit /b 1
)

REM --- Build (if requested) ---
if /i "%1"=="build" goto :build
if /i "%1"=="rebuild" goto :build
echo.
echo Configuration complete. Run 'configure-msvc71.bat build' to compile.
exit /b 0

:build
echo.
echo Building Release with MSVC 7.1 ...
"%CMAKE_EXE%" --build "%ROOT%\build-71" --config Release
if errorlevel 1 (
    echo.
    echo ERROR: Build failed.
    exit /b 1
)
echo.
echo Build complete. DLLs in: %ROOT%\build-71\bin\
exit /b 0
