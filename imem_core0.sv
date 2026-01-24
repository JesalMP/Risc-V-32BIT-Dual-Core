`timescale 1ns / 1ps

module imem_core0 #(
  parameter IMEM_BYTES = 4096,
  localparam WORDS     = IMEM_BYTES/4,
  localparam AW        = $clog2(WORDS)
) (
  input  logic         clk,
  input  logic         en,
  input  logic [31:0]  pc,
  output logic [31:0]  instr
);
  wire [AW-1:0] widx = pc[AW+1:2];

  (* rom_style = "block" *) logic [31:0] rom [0:WORDS-1];

  initial begin
    // Core 0 program - Basic arithmetic
    rom[0] = 32'b00000000000100000000001100010011; // addi x6,  x0, 1
    rom[1] = 32'b00000000001000000000001110010011; // addi x7,  x0, 2
    rom[2] = 32'b00000000011001100000010000110011; // add  x8,  x6, x7
    rom[3] = 32'b00000000100001000000010010110011; // add  x9,  x8, x8
    rom[4] = 32'b00000000001100000000010100010011; // addi x10, x0, 3
    rom[5] = 32'b00000000101001010000010110110011; // add  x11, x10, x10
    rom[6] = 32'b11111110000000000000000001101111; // jal  x0, -32 (loop back to start)
  end

  always_ff @(posedge clk) begin
    if (en)
      instr <= rom[widx];
  end
endmodule
