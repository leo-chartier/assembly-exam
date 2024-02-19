@echo off
:: ------------------------------------
:: DosBox launcher for Windows.
:: (DosBox must be installed to default location  first)
:: ------------------------------------

:: ------------------------------------
set "ROOT_DIR=%~dp0"
set "BIN_DIR=%ROOT_DIR%bin"
set "DOSBOX_BIN=%ProgramFiles(x86)%\DOSBox-0.74-3\DOSBox.exe"
set "CONFIG_LOC=%ROOT_DIR%"

:: ------------------------------------
:: Launch DosBox and,
:: mount the bin directory as C:,
:: change drive to C:
:: and launch "EXAM.COM"
"%DOSBOX_BIN%" -c "MOUNT c %BIN_DIR%" -c "C:" -c "exam"
