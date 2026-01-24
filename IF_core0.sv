`timescale 1ns / 1ps

module IF_core0 (
    input logic clk,
    input logic rst_n,
    input logic branch_taken,
    input logic [31:0] branch_target,
    input logic stall,
    output logic [31:0] instr_out,
    output logic [31:0] pc_out
);

  logic [31:0] instr_from_IF;
  logic [31:0] pc;
  logic [31:0] pc_to_IMEM;
  logic [31:0] pc_next;

  imem_core0 imem_inst (
      .clk(clk),
      .en(1'b1),
      .pc(pc_to_IMEM),
      .instr(instr_from_IF)
  );

  always_comb begin
    if (branch_taken) begin
      pc_next = branch_target;
    end else begin
      pc_next = pc + 4;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc <= 32'b0;
      instr_out <= 32'b0;
      pc_out <= 32'b0;
    end else begin
      if (!stall) begin
        pc_to_IMEM <= pc;
        pc <= pc_next;
      end
      instr_out <= instr_from_IF;
      pc_out <= pc;
    end
    $strobe("[CORE0] IF Stage - PC: %08h, Instruction: %032b", pc, instr_from_IF);
  end
  
endmodule
