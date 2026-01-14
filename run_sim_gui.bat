@echo off
REM Vivado Command-line Simulation Script with GUI Waveform Viewer
REM This script compiles, elaborates, and runs simulation with waveform display

REM Add Vivado to PATH
set PATH=C:\Xilinx\2025.1\Vivado\bin;%PATH%

echo ========================================
echo RISC-V SystemVerilog Simulation (GUI)
echo ========================================

REM Clean previous simulation files
if exist xsim.dir rmdir /s /q xsim.dir
if exist *.jou del /q *.jou
if exist *.log del /q *.log
if exist *.pb del /q *.pb
if exist *.wdb del /q *.wdb

echo.
echo [1/3] Compiling SystemVerilog files...
set SV_FILES=
for %%f in (*.sv) do call set SV_FILES=%%SV_FILES%% %%f
call xvlog --sv %SV_FILES%

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Compilation failed!
    exit /b 1
)

echo.
echo [2/3] Elaborating design...
call xelab -debug typical top -s top_sim

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Elaboration failed!
    exit /b 1
)

echo.
echo [3/3] Launching simulation with GUI...
call xsim top_sim -gui

echo.
echo ========================================
echo Simulation completed!
echo ========================================
