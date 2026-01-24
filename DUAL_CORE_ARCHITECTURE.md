# Dual-Core RISC-V - True Independent Core Architecture (MARKDOWN WRITTEN W/ HELP of CHATGPT)

## Component Independence Verification

### Core 0 (riscv_core #CORE_ID=0)
```
┌─────────────────────────────────────────────────────────────┐
│                        CORE 0                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────── IF Stage (IF_core0) ──────────┐             │
│  │ • PC register (32-bit) [SEPARATE]        │             │
│  │ • PC increment logic                     │             │
│  │ • Branch/Jump target mux                 │             │
│  │ • imem_core0 (instruction ROM)           │             │
│  │ • IF/ID pipeline register                │             │
│  └──────────────────────────────────────────┘             │
│                      ↓                                      │
│  ┌─────────── ID Stage ─────────────────────┐             │
│  │ • control_unit instance [SEPARATE]       │             │
│  │ • gprs instance (32x32 regs) [SEPARATE]  │             │
│  │   - x0-x31 register file                 │             │
│  │   - Write-back from Core 0 WB only       │             │
│  │ • Immediate generation                   │             │
│  │ • ID/EX pipeline registers               │             │
│  └──────────────────────────────────────────┘             │
│                      ↓                                      │
│  ┌─────────── EX Stage ─────────────────────┐             │
│  │ • ALU instance [SEPARATE]                │             │
│  │   - 10 operations (AND/OR/ADD/...)       │             │
│  │ • Branch condition logic                 │             │
│  │ • Branch target calculation              │             │
│  │ • EX/MEM pipeline registers              │             │
│  └──────────────────────────────────────────┘             │
│                      ↓                                      │
│  ┌─────────── MEM Stage ────────────────────┐             │
│  │ • Memory interface to arbiter            │             │
│  │ • MEM/WB pipeline registers [SEPARATE]   │             │
│  └──────────────────────────────────────────┘             │
│                      ↓                                      │
│  ┌─────────── WB Stage ─────────────────────┐             │
│  │ • Result mux (ALU vs Memory)             │             │
│  │ • Write-back to Core 0 GPRs only         │             │
│  └──────────────────────────────────────────┘             │
│                                                             │
│  ┌─────────── Hazard Detection Unit ────────┐             │
│  │ • Load-use hazard detection [SEPARATE]   │             │
│  │ • Forwarding signal generation           │             │
│  │ • Stall control for Core 0 only          │             │
│  └──────────────────────────────────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Core 1 (riscv_core #CORE_ID=1)
```
┌─────────────────────────────────────────────────────────────┐
│                        CORE 1                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────── IF Stage (IF_core1) ──────────┐             │
│  │ • PC register (32-bit) [SEPARATE]        │             │
│  │ • PC increment logic                     │             │
│  │ • Branch/Jump target mux                 │             │
│  │ • imem_core1 (instruction ROM)           │             │
│  │ • IF/ID pipeline register                │             │
│  └──────────────────────────────────────────┘             │
│                      ↓                                      │
│  ┌─────────── ID Stage ─────────────────────┐             │
│  │ • control_unit instance [SEPARATE]       │             │
│  │ • gprs instance (32x32 regs) [SEPARATE]  │             │
│  │   - x0-x31 register file                 │             │
│  │   - Write-back from Core 1 WB only       │             │
│  │ • Immediate generation                   │             │
│  │ • ID/EX pipeline registers               │             │
│  └──────────────────────────────────────────┘             │
│                      ↓                                      │
│  ┌─────────── EX Stage ─────────────────────┐             │
│  │ • ALU instance [SEPARATE]                │             │
│  │   - 10 operations (AND/OR/ADD/...)       │             │
│  │ • Branch condition logic                 │             │
│  │ • Branch target calculation              │             │
│  │ • EX/MEM pipeline registers              │             │
│  └──────────────────────────────────────────┘             │
│                      ↓                                      │
│  ┌─────────── MEM Stage ────────────────────┐             │
│  │ • Memory interface to arbiter            │             │
│  │ • MEM/WB pipeline registers [SEPARATE]   │             │
│  └──────────────────────────────────────────┘             │
│                      ↓                                      │
│  ┌─────────── WB Stage ─────────────────────┐             │
│  │ • Result mux (ALU vs Memory)             │             │
│  │ • Write-back to Core 1 GPRs only         │             │
│  └──────────────────────────────────────────┘             │
│                                                             │
│  ┌─────────── Hazard Detection Unit ────────┐             │
│  │ • Load-use hazard detection [SEPARATE]   │             │
│  │ • Forwarding signal generation           │             │
│  │ • Stall control for Core 1 only          │             │
│  └──────────────────────────────────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Resource Count

### Per Core (Core 0 and Core 1 each have):
| Component | Quantity | Bits | Details |
|-----------|----------|------|---------|
| **PC Register** | 1 | 32 | Program counter |
| **IF/ID Registers** | ~70 | ~70 | Instruction + PC |
| **GPR File (x0-x31)** | 32 | 1024 | 32 registers × 32 bits |
| **ID/EX Registers** | ~150 | ~150 | Data + Control signals |
| **ALU** | 1 | 32 | Arithmetic/Logic unit |
| **EX/MEM Registers** | ~80 | ~80 | Results + Control |
| **MEM/WB Registers** | ~70 | ~70 | Memory data + Control |
| **Control Unit** | 1 | - | Decode logic |
| **Hazard Unit** | 1 | - | Stall/Forward logic |

### Total Resources:
- **2 Program Counters** (one per core)
- **64 General Purpose Registers** (32 per core)
- **2 ALUs** (one per core)
- **2 Control Units** (one per core)
- **2 Hazard Detection Units** (one per core)
- **~740 Pipeline Register Bits per Core** = **~1480 bits total**

### Shared Resources:
- **1 Data Memory** (4096 bytes, arbitrated)
- **1 Memory Arbiter** (FSM + muxes)

## Independence Proof

### 1. Register File Independence
```systemverilog
// From ID.sv - Each ID instantiation creates separate gprs
gprs gprs_inst (
    .clk(clk),
    .rst_n(rst_n),
    .we(wb_enable),        // Core-specific write enable
    .waddr(wb_addr),       // Core-specific write address
    .wdata(wb_data),       // Core-specific write data
    .raddr1(rs1_addr),     // Core-specific read
    .raddr2(rs2_addr),     // Core-specific read
    .rdata1(rs1_data),     // Core-specific output
    .rdata2(rs2_data)      // Core-specific output
);
// Core 0's gprs_inst is DIFFERENT from Core 1's gprs_inst
// Writing to Core 0's x6 does NOT affect Core 1's x6
```

### 2. PC Independence
```systemverilog
// From IF_core0.sv
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pc_to_IMEM <= 32'b0;  // Core 0's PC
    else if (!stall)
        pc_to_IMEM <= pc_next;
end

// From IF_core1.sv  
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        pc_to_IMEM <= 32'b0;  // Core 1's PC (different register!)
    else if (!stall)
        pc_to_IMEM <= pc_next;
end
// These are two separate registers!
```

### 3. ALU Independence
```systemverilog
// From EX.sv - Each EX instantiation creates separate ALU
ALU alu_inst (
    .a(alu_operand_a),     // Core-specific input A
    .b(alu_operand_b),     // Core-specific input B
    .alu_control(alu_control),
    .result(alu_result),   // Core-specific result
    .zero(alu_zero)
);
// Core 0 and Core 1 have different ALU instances
```

### 4. Pipeline Register Independence
Every stage has `always_ff` blocks that create separate registers:
```systemverilog
// Example from EX.sv - These registers exist per-core
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_addr_out <= 5'b0;
        funct3_out <= 3'b0;
        RegWrite_out <= 1'b0;
        // ... etc
    end else if (!stall_in) begin
        rd_addr_out <= rd_addr_in;
        // ... etc
    end
end
// Each core's EX stage has its own set of these registers
```

### 5. Hazard Detection Independence
```systemverilog
// From riscv_core.sv - Each core instantiates its own HDU
hazard_detection_unit hdu_inst (
    .id_rs1(rs1_addr_from_ID),      // Core-specific
    .id_rs2(rs2_addr_from_ID),      // Core-specific
    .ex_rd(rd_addr_from_EX),        // Core-specific
    .stall(stall_pipeline),         // Core-specific stall
    .forward_a(forward_a),          // Core-specific forwarding
    .forward_b(forward_b)           // Core-specific forwarding
);
// Hazards in Core 0 only affect Core 0's pipeline
```

## Memory Interaction

Only the **MEM stage** interacts with shared resources:

```
Core 0 MEM ──┐
             ├──> Memory Arbiter ──> Shared Data Memory
Core 1 MEM ──┘

• Arbiter serializes access (round-robin)
• Each core waits for mem_ready signal
• No interference between cores' pipelines
• Only data memory is shared, not instruction memory
```

## Test Program Verification

### Core 0 Program (uses x6-x11):
```
Write to: x6, x7, x8, x9, x10, x11
Read from: x6, x7, x8, x10 (and x0)
```

### Core 1 Program (uses x12-x17):
```
Write to: x12, x13, x14, x15, x16, x17
Read from: x12, x13, x14, x16 (and x0)
```

**No register conflicts** - Different register numbers ensure each core operates on its own register file.

## Conclusion

✅ **TRUE DUAL-CORE** - Each core is completely independent
✅ **Separate State** - All pipeline registers, PC, GPRs are per-core
✅ **Separate Execution** - ALU, control unit, hazard detection per-core
✅ **Only Shared** - Data memory (arbitrated for mutual exclusion)
✅ **Scalable** - Could extend to 4, 8, or more cores easily

The design is a **proper multi-core processor** with:
- **Spatial parallelism** (two cores execute simultaneously)
- **Thread-level parallelism** (each core runs independent thread)
- **Shared memory model** (both cores can access common data)
