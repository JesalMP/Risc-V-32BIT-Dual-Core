`timescale 1ns / 1ps

module IF (
    input logic clk,
    input logic rst_n,
    input logic branch_taken,
    input logic [31:0] branch_target,
    input logic stall,
    output logic [31:0] instr_out,
    output logic [31:0] pc_out
);

  // Instantiate instruction memory
  logic [31:0] instr_from_IF;
  logic [31:0] pc;
  logic [31:0] pc_to_IMEM;
  logic [31:0] pc_next;

  imem_sync imem_inst (
      .clk(clk),
      .en(1'b1),          // Always enable for instruction fetch
      .pc(pc_to_IMEM),
      .instr(instr_from_IF)
  );

  // Next PC logic
  always_comb begin
    if (branch_taken) begin
      pc_next = branch_target;
    end else begin
      pc_next = pc + 4;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc <= 32'b0; // Reset program counter
      instr_out <= 32'b0; // Reset instruction output
      pc_out <= 32'b0;
    end else begin
      if (!stall) begin
        pc_to_IMEM <= pc; // Update PC for instruction memory
        pc <= pc_next; // Update program counter
      end
      instr_out <= instr_from_IF; // Output the fetched instruction
      pc_out <= pc; // Output current PC
    end
    $strobe("IF Stage - PC: %08h, Instruction: %032b", pc, instr_from_IF);
  end
  
endmodule