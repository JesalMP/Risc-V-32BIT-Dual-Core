`timescale 1ns / 1ps

module dual_core_riscv(
    input logic clk,
    input logic rst_n
);

    // Core 0 signals
    logic [31:0] core0_mem_addr;
    logic [31:0] core0_mem_write_data;
    logic [2:0] core0_mem_funct3;
    logic core0_mem_read;
    logic core0_mem_write;
    logic [31:0] core0_mem_read_data;
    logic core0_mem_ready;
    
    // Core 1 signals
    logic [31:0] core1_mem_addr;
    logic [31:0] core1_mem_write_data;
    logic [2:0] core1_mem_funct3;
    logic core1_mem_read;
    logic core1_mem_write;
    logic [31:0] core1_mem_read_data;
    logic core1_mem_ready;
    
    // Shared memory signals
    logic [31:0] shared_mem_addr;
    logic [31:0] shared_mem_write_data;
    logic [2:0] shared_mem_funct3;
    logic shared_mem_read;
    logic shared_mem_write;
    logic [31:0] shared_mem_read_data;
    
    // Core 0 instance
    riscv_core #(.CORE_ID(0)) core0 (
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr_out(core0_mem_addr),
        .mem_write_data_out(core0_mem_write_data),
        .mem_funct3_out(core0_mem_funct3),
        .mem_read_out(core0_mem_read),
        .mem_write_out(core0_mem_write),
        .mem_read_data_in(core0_mem_read_data),
        .mem_ready_in(core0_mem_ready)
    );
    
    // Core 1 instance
    riscv_core #(.CORE_ID(1)) core1 (
        .clk(clk),
        .rst_n(rst_n),
        .mem_addr_out(core1_mem_addr),
        .mem_write_data_out(core1_mem_write_data),
        .mem_funct3_out(core1_mem_funct3),
        .mem_read_out(core1_mem_read),
        .mem_write_out(core1_mem_write),
        .mem_read_data_in(core1_mem_read_data),
        .mem_ready_in(core1_mem_ready)
    );
    
    // Memory arbiter
    memory_arbiter arbiter (
        .clk(clk),
        .rst_n(rst_n),
        .core0_addr(core0_mem_addr),
        .core0_write_data(core0_mem_write_data),
        .core0_funct3(core0_mem_funct3),
        .core0_mem_read(core0_mem_read),
        .core0_mem_write(core0_mem_write),
        .core0_read_data(core0_mem_read_data),
        .core0_ready(core0_mem_ready),
        .core1_addr(core1_mem_addr),
        .core1_write_data(core1_mem_write_data),
        .core1_funct3(core1_mem_funct3),
        .core1_mem_read(core1_mem_read),
        .core1_mem_write(core1_mem_write),
        .core1_read_data(core1_mem_read_data),
        .core1_ready(core1_mem_ready),
        .mem_addr(shared_mem_addr),
        .mem_write_data(shared_mem_write_data),
        .mem_funct3(shared_mem_funct3),
        .mem_read(shared_mem_read),
        .mem_write(shared_mem_write),
        .mem_read_data(shared_mem_read_data)
    );
    
    // Shared data memory
    data_mem shared_data_mem (
        .clk(clk),
        .rst_n(rst_n),
        .address(shared_mem_addr),
        .write_data(shared_mem_write_data),
        .funct3(shared_mem_funct3),
        .mem_read(shared_mem_read),
        .mem_write(shared_mem_write),
        .read_data(shared_mem_read_data)
    );

endmodule
