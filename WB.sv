`timescale 1ns / 1ps

module WB (
    input logic clk,
    input logic rst_n,
    
    // Data inputs from MEM stage
    input logic [31:0] mem_data_in,
    input logic [31:0] alu_result_in,
    input logic [4:0] rd_addr_in,
    
    // Control signals
    input logic RegWrite_in,
    input logic MemtoReg_in,
    
    // Outputs
    output logic [31:0] wb_data_out,
    output logic [4:0] wb_addr_out,
    output logic wb_enable_out
);

    // Write-back data multiplexer
    assign wb_data_out = MemtoReg_in ? mem_data_in : alu_result_in;
    assign wb_addr_out = rd_addr_in;
    assign wb_enable_out = RegWrite_in;
    
    // Debug output
    always_ff @(posedge clk) begin
        if (RegWrite_in && rd_addr_in != 5'b0) begin
            $strobe("WB Stage - Write: x%0d <= %08h (from %s)", 
                    rd_addr_in, wb_data_out, MemtoReg_in ? "MEM" : "ALU");
        end
    end

endmodule
