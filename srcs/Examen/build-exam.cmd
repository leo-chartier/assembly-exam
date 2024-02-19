@echo off
:: ------------------------------------
:: Examen NASM build for Windows.
:: ------------------------------------

set "SCRIPT_DIR=%~dp0"
set "ROOT_DIR=%SCRIPT_DIR%..\.."
set "NASM=%ROOT_DIR%\nasm\nasm"
set "BIN_DIR=%ROOT_DIR%\bin"

:: ------------------------------------
:: Invoke nasm to generate program image:
"%NASM%" exam.asm ^
    -f bin ^
    -o "%BIN_DIR%\exam.com"

pause
