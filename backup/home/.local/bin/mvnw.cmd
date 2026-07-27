@echo off
setlocal enabledelayedexpansion

set "current=%cd%"

:loop
if exist "%current%\mvnw.cmd" (
    call "%current%\mvnw.cmd" %*
    exit /b %errorlevel%
)

if exist "%current%\mvnw" (
    call "%current%\mvnw" %*
    exit /b %errorlevel%
)

for %%I in ("%current%\..") do set "parent=%%~fI"
if "%parent%"=="%current%" goto notfound
set "current=%parent%"
goto loop

:notfound
echo Error: mvnw not found in current directory or any parent ^>&2
exit /b 1
