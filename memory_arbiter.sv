`timescale 1ns / 1ps

module memory_arbiter (
    input logic clk,
    input logic rst_n,
    
    // Core 0 memory requests
    input logic [31:0] core0_addr,
    input logic [31:0] core0_write_data,
    input logic [2:0] core0_funct3,
    input logic core0_mem_read,
    input logic core0_mem_write,
    output logic [31:0] core0_read_data,
    output logic core0_ready,
    
    // Core 1 memory requests
    input logic [31:0] core1_addr,
    input logic [31:0] core1_write_data,
    input logic [2:0] core1_funct3,
    input logic core1_mem_read,
    input logic core1_mem_write,
    output logic [31:0] core1_read_data,
    output logic core1_ready,
    
    // Actual memory interface
    output logic [31:0] mem_addr,
    output logic [31:0] mem_write_data,
    output logic [2:0] mem_funct3,
    output logic mem_read,
    output logic mem_write,
    input logic [31:0] mem_read_data
);

    // Arbitration state
    typedef enum logic [1:0] {
        IDLE,
        SERVE_CORE0,
        SERVE_CORE1
    } arbiter_state_t;
    
    arbiter_state_t state, next_state;
    
    // State machine
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // Next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                // Priority to Core 0
                if (core0_mem_read || core0_mem_write)
                    next_state = SERVE_CORE0;
                else if (core1_mem_read || core1_mem_write)
                    next_state = SERVE_CORE1;
            end
            
            SERVE_CORE0: begin
                // Serve for 1 cycle, then check if Core 1 needs service
                if (core1_mem_read || core1_mem_write)
                    next_state = SERVE_CORE1;
                else if (core0_mem_read || core0_mem_write)
                    next_state = SERVE_CORE0;
                else
                    next_state = IDLE;
            end
            
            SERVE_CORE1: begin
                // Serve for 1 cycle, then check if Core 0 needs service
                if (core0_mem_read || core0_mem_write)
                    next_state = SERVE_CORE0;
                else if (core1_mem_read || core1_mem_write)
                    next_state = SERVE_CORE1;
                else
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Output muxing
    always_comb begin
        // Default values
        mem_addr = 32'b0;
        mem_write_data = 32'b0;
        mem_funct3 = 3'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        core0_ready = 1'b0;
        core1_ready = 1'b0;
        core0_read_data = mem_read_data;
        core1_read_data = mem_read_data;
        
        case (state)
            SERVE_CORE0: begin
                mem_addr = core0_addr;
                mem_write_data = core0_write_data;
                mem_funct3 = core0_funct3;
                mem_read = core0_mem_read;
                mem_write = core0_mem_write;
                core0_ready = 1'b1;
                core0_read_data = mem_read_data;
            end
            
            SERVE_CORE1: begin
                mem_addr = core1_addr;
                mem_write_data = core1_write_data;
                mem_funct3 = core1_funct3;
                mem_read = core1_mem_read;
                mem_write = core1_mem_write;
                core1_ready = 1'b1;
                core1_read_data = mem_read_data;
            end
            
            default: begin
                // IDLE state - no memory access
                core0_ready = 1'b1;  // Always ready when not accessing
                core1_ready = 1'b1;
            end
        endcase
    end

endmodule
