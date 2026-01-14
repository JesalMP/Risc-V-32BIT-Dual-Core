`timescale 1ns / 1ps

module hazard_detection_unit (
    // ID stage signals
    input logic [4:0] id_rs1,
    input logic [4:0] id_rs2,
    
    // EX stage signals
    input logic [4:0] ex_rd,
    input logic ex_mem_read,
    input logic ex_reg_write,
    
    // MEM stage signals
    input logic [4:0] mem_rd,
    input logic mem_reg_write,
    
    // WB stage signals
    input logic [4:0] wb_rd,
    input logic wb_reg_write,
    
    // Control outputs
    output logic stall,
    output logic [1:0] forward_a,  // 00: no forward, 01: from MEM, 10: from WB, 11: from EX
    output logic [1:0] forward_b
);

    // Load-use hazard detection (requires stall)
    always_comb begin
        stall = 1'b0;
        
        // If EX stage is doing a load and ID stage needs that data
        if (ex_mem_read && 
            ((ex_rd == id_rs1 && id_rs1 != 5'b0) || 
             (ex_rd == id_rs2 && id_rs2 != 5'b0))) begin
            stall = 1'b1;
        end
    end
    
    // Forwarding logic for rs1
    always_comb begin
        forward_a = 2'b00; // No forwarding by default
        
        // Forward from MEM stage (highest priority after load-use)
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == id_rs1)) begin
            forward_a = 2'b01;
        end
        // Forward from WB stage
        else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == id_rs1)) begin
            forward_a = 2'b10;
        end
        // Forward from EX stage (for back-to-back ALU operations)
        else if (ex_reg_write && !ex_mem_read && (ex_rd != 5'b0) && (ex_rd == id_rs1)) begin
            forward_a = 2'b11;
        end
    end
    
    // Forwarding logic for rs2
    always_comb begin
        forward_b = 2'b00; // No forwarding by default
        
        // Forward from MEM stage (highest priority after load-use)
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == id_rs2)) begin
            forward_b = 2'b01;
        end
        // Forward from WB stage
        else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == id_rs2)) begin
            forward_b = 2'b10;
        end
        // Forward from EX stage (for back-to-back ALU operations)
        else if (ex_reg_write && !ex_mem_read && (ex_rd != 5'b0) && (ex_rd == id_rs2)) begin
            forward_b = 2'b11;
        end
    end

endmodule
