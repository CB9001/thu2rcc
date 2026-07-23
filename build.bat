@echo off
setlocal enabledelayedexpansion

rem Check if cl.exe is already in PATH
where cl.exe >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    goto :COMPILE
)

echo Searching for MSVC compiler (cl.exe) via vswhere...

rem Use vswhere to find Visual Studio installation and vcvars64.bat
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "!VSWHERE!" (
    for /f "usebackq tokens=*" %%i in (`"!VSWHERE!" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
        set "VS_DIR=%%i"
        if exist "!VS_DIR!\VC\Auxiliary\Build\vcvars64.bat" (
            echo Found Visual Studio at "!VS_DIR!"
            call "!VS_DIR!\VC\Auxiliary\Build\vcvars64.bat" >nul
            goto :COMPILE
        )
    )
)

:NOT_FOUND
echo Error: cl.exe (MSVC C++ compiler) could not be found automatically.
echo.
echo Please update your PATH with the location of cl.exe, then re-run this script:
echo (Note: The path below is an example and may vary based on your Visual Studio version/edition)
echo.
echo   $env:Path = 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\YOURVERSION\bin\Hostx64\x64;' + $env:Path
echo   .\build.bat
echo.
exit /b 1

:COMPILE
where cl.exe >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    goto :NOT_FOUND
)

echo Compiling Windows resource file...
rc.exe /nologo /fo res\resource.res res\resource.rc
echo Building thu2rcc using nvcc...
nvcc -O3 src/cheat_cracker.cu res\resource.res -o thu2rcc.exe
if %ERRORLEVEL% EQU 0 (
    echo Build successful: thu2rcc.exe
) else (
    echo Build failed with error code %ERRORLEVEL%.
)
