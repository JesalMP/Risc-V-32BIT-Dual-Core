@echo off
REM Vivado Command-line Simulation Script for Dual-Core RISC-V

REM Add Vivado to PATH
set PATH=C:\Xilinx\2025.1\Vivado\bin;%PATH%

echo ========================================
echo Dual-Core RISC-V Simulation
echo ========================================

REM Clean previous build
if exist xsim.dir rmdir /s /q xsim.dir
if exist *.jou del /q *.jou
if exist *.log del /q *.log
if exist *.pb del /q *.pb
if exist *.wdb del /q *.wdb

echo.
echo [1/3] Compiling SystemVerilog files for dual-core design...

REM Compile core modules
call xvlog --sv ALU.sv
call xvlog --sv control_unit.sv
call xvlog --sv gprs.sv
call xvlog --sv hazard_detection_unit.sv
call xvlog --sv imem_core0.sv
call xvlog --sv imem_core1.sv
call xvlog --sv IF_core0.sv
call xvlog --sv IF_core1.sv
call xvlog --sv ID.sv
call xvlog --sv EX.sv
call xvlog --sv data_mem.sv
call xvlog --sv memory_arbiter.sv
call xvlog --sv WB.sv
call xvlog --sv riscv_core.sv
call xvlog --sv dual_core_riscv.sv
call xvlog --sv top_dual.sv

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Compilation failed!
    pause
    exit /b 1
)

echo.
echo [2/3] Elaborating dual-core design...
call xelab -debug typical top_dual -s top_dual_sim

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Elaboration failed!
    pause
    exit /b 1
)

echo.
echo [3/3] Running dual-core simulation...
call xsim top_dual_sim -runall

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Simulation failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Dual-core simulation completed!
echo ========================================
pause
