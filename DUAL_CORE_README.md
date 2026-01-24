# Dual-Core RISC-V Architecture (MARKDOWN WRITTEN W/ HELP of CHATGPT)

## Overview
This project implements a 32-bit dual-core RISC-V processor with:
- **Two independent cores** (Core 0 and Core 1)
- **Separate instruction memories** for each core
- **Shared data memory** with arbitration
- **5-stage pipeline** per core (IF→ID→EX→MEM→WB)

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    Dual-Core RISC-V System                   │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────┐        ┌─────────────────────┐    │
│  │      Core 0         │        │      Core 1         │    │
│  ├─────────────────────┤        ├─────────────────────┤    │
│  │ IF (imem_core0)     │        │ IF (imem_core1)     │    │
│  │ ID (decode/gprs)    │        │ ID (decode/gprs)    │    │
│  │ EX (ALU)            │        │ EX (ALU)            │    │
│  │ MEM (interface)     │        │ MEM (interface)     │    │
│  │ WB (writeback)      │        │ WB (writeback)      │    │
│  └──────────┬──────────┘        └──────────┬──────────┘    │
│             │                              │               │
│             └──────────┬───────────────────┘               │
│                        ▼                                   │
│              ┌──────────────────┐                         │
│              │  Memory Arbiter  │                         │
│              │  (Round-Robin)   │                         │
│              └─────────┬────────┘                         │
│                        ▼                                   │
│              ┌──────────────────┐                         │
│              │  Shared Data Mem │                         │
│              │   (4096 bytes)   │                         │
│              └──────────────────┘                         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Core Modules
- **riscv_core.sv**: Parameterized core module (CORE_ID=0 or 1)
  - Uses generate block to instantiate appropriate IF stage
  - Contains full 5-stage pipeline
  - Separate register file per core (32 registers each)
  - Hazard detection and forwarding unit

### 2. Instruction Memories (Separate)
- **imem_core0.sv**: Core 0's instruction ROM
  - Program uses registers x6-x11
  - Contains: addi, add, jal instructions
  - 4096-byte capacity

- **imem_core1.sv**: Core 1's instruction ROM
  - Program uses registers x12-x17
  - Contains: addi, add, sub, jal instructions
  - 4096-byte capacity

### 3. Instruction Fetch Stages (Separate)
- **IF_core0.sv**: Fetch stage for Core 0
  - Instantiates imem_core0
  - Debug output with [CORE0] prefix

- **IF_core1.sv**: Fetch stage for Core 1
  - Instantiates imem_core1
  - Debug output with [CORE1] prefix

### 4. Memory Arbiter
- **memory_arbiter.sv**: Arbitrates shared data memory access
  - 3-state FSM: IDLE → SERVE_CORE0 → SERVE_CORE1
  - Priority to Core0 when idle
  - Round-robin scheduling
  - 1-cycle service per core
  - Generates ready signals for each core

### 5. Shared Memory
- **data_mem.sv**: Shared 4096-byte data memory
  - Supports byte, half-word, and word access
  - Handles signed/unsigned loads
  - Single port (arbitrated between cores)

### 6. Top-Level Modules
- **dual_core_riscv.sv**: Dual-core system integrator
  - Instantiates 2 cores with parameters
  - Instantiates memory arbiter
  - Instantiates shared data memory
  - Wires all interconnections

- **top_dual.sv**: Testbench for dual-core system
  - 100MHz clock (10ns period)
  - 20ns reset sequence
  - 500ns simulation time
  - Monitors both cores' execution

## Test Programs

### Core 0 Program (registers x6-x11):
```assembly
0x00: addi x6, x0, 1      # x6 = 1
0x04: addi x7, x0, 2      # x7 = 2
0x08: add  x8, x6, x7     # x8 = x6 + x7 = 3
0x0C: add  x9, x8, x8     # x9 = x8 + x8 = 6
0x10: addi x10, x0, 3     # x10 = 3
0x14: add  x11, x10, x10  # x11 = x10 + x10 = 6
0x18: jal  x0, -32        # Jump back to 0x00 (infinite loop)
```

### Core 1 Program (registers x12-x17):
```assembly
0x00: addi x12, x0, 5      # x12 = 5
0x04: addi x13, x0, 6      # x13 = 6
0x08: add  x14, x12, x13   # x14 = x12 + x13 = 11
0x0C: sub  x15, x14, x13   # x15 = x14 - x13 = 5
0x10: addi x16, x0, 8      # x16 = 8
0x14: add  x17, x16, x16   # x17 = x16 + x16 = 16
0x18: jal  x0, -32         # Jump back to 0x00 (infinite loop)
```

## How to Run

### Dual-Core Simulation:
```batch
.\run_dual_sim.bat
```
This will:
1. Clean previous simulation files
2. Compile all SystemVerilog modules
3. Elaborate the dual-core design
4. Run the simulation for 500ns

### Single-Core Simulation (original):
```batch
.\run_sim.bat
```

## Features Implemented

✅ Dual-core execution with independent pipelines
✅ Separate instruction memories per core
✅ Shared data memory with round-robin arbitration
✅ Full 5-stage pipeline per core
✅ Hazard detection and data forwarding
✅ Jump and branch support with pipeline flush
✅ All RISC-V RV32I base instructions
✅ Memory ready signals for arbitration
✅ Core-specific debug output

## Known Limitations

1. **Jump Target Issue**: After the JAL instruction, the PC becomes misaligned. This needs debugging in the EX stage branch target calculation.

2. **Memory Arbitration**: Currently uses simple round-robin. Could be enhanced with priority levels or more sophisticated scheduling.

3. **No Cache**: Direct access to shared memory without caching could become a bottleneck.

4. **No Interrupts**: No interrupt handling mechanism implemented yet.

5. **Limited Test Programs**: Only basic arithmetic operations tested so far.

## Files Structure

```
Risc-V-32BIT-Dual-Core/
├── ALU.sv                      # ALU with 10 operations
├── control_unit.sv             # Instruction decoder
├── gprs.sv                     # 32-register file
├── hazard_detection_unit.sv    # Stall and forwarding logic
├── IF_core0.sv                 # Fetch stage for Core 0
├── IF_core1.sv                 # Fetch stage for Core 1
├── imem_core0.sv               # Instruction ROM for Core 0
├── imem_core1.sv               # Instruction ROM for Core 1
├── ID.sv                       # Decode stage
├── EX.sv                       # Execute stage
├── MEM.sv                      # Memory stage (original)
├── WB.sv                       # Writeback stage
├── data_mem.sv                 # Shared data memory
├── memory_arbiter.sv           # Memory access arbiter
├── riscv_core.sv               # Single core wrapper
├── dual_core_riscv.sv          # Dual-core top module
├── top_dual.sv                 # Dual-core testbench
├── run_dual_sim.bat            # Dual-core simulation script
├── riscV.sv                    # Original single-core
├── top.sv                      # Original single-core testbench
└── run_sim.bat                 # Original simulation script
```

## Next Steps

1. **Fix Jump Target**: Debug the branch_target calculation in EX stage
2. **Add Memory Tests**: Write programs that access shared data memory
3. **Test Arbitration**: Verify both cores can access memory without conflicts
4. **Add Cache**: Implement simple cache for each core
5. **Performance Counters**: Add counters for stalls, arbitration waits, etc.
6. **More Instructions**: Implement remaining RV32I instructions
7. **Interrupts**: Add interrupt controller for inter-core communication

## Compilation Notes

- Uses Xilinx Vivado 2025.1 tools (xvlog, xelab, xsim)
- SystemVerilog with timescale 1ns/1ps
- Debug outputs for all pipeline stages
- Multi-threading enabled (18 threads) during elaboration
