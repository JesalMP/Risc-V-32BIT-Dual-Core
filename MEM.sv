`timescale 1ns / 1ps

module MEM (
    input logic clk,
    input logic rst_n,
    input logic stall_in = 0,
    
    // Data inputs from EX stage
    input logic [31:0] alu_result_in,
    input logic [31:0] rs2_in,
    input logic [4:0] rd_addr_in,
    input logic [2:0] funct3_in,
    
    // Control signals
    input logic RegWrite_in,
    input logic MemRead_in,
    input logic MemWrite_in,
    input logic MemtoReg_in,
    
    // Outputs
    output logic [31:0] mem_data_out,
    output logic [31:0] alu_result_out,
    output logic [4:0] rd_addr_out,
    output logic RegWrite_out,
    output logic MemtoReg_out,
    output logic stall_out
);

    logic [31:0] read_data;
    
    // Data memory instantiation
    data_mem dmem_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(MemRead_in),
        .mem_write(MemWrite_in),
        .address(alu_result_in),
        .write_data(rs2_in),
        .funct3(funct3_in),
        .read_data(read_data)
    );
    
    // Pipeline registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_data_out <= 32'b0;
            alu_result_out <= 32'b0;
            rd_addr_out <= 5'b0;
            RegWrite_out <= 1'b0;
            MemtoReg_out <= 1'b0;
            stall_out <= 1'b0;
        end else if (stall_in) begin
            // Hold current values if stalled
            stall_out <= 1'b1;
        end else begin
            mem_data_out <= read_data;
            alu_result_out <= alu_result_in;
            rd_addr_out <= rd_addr_in;
            RegWrite_out <= RegWrite_in;
            MemtoReg_out <= MemtoReg_in;
            stall_out <= 1'b0;
            
            if (MemRead_in)
                $strobe("MEM Stage - Load: addr=%08h data=%08h | RD: x%0d", alu_result_in, read_data, rd_addr_in);
            else if (MemWrite_in)
                $strobe("MEM Stage - Store: addr=%08h data=%08h", alu_result_in, rs2_in);
            else
                $strobe("MEM Stage - Pass: ALU=%08h | RD: x%0d", alu_result_in, rd_addr_in);
        end
    end

endmodule
