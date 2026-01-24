`timescale 1ns / 1ps

module imem_core1 #(
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
    // Core 1 program - Different operations
    rom[0] = 32'b00000000010100000000011000010011; // addi x12, x0, 5
    rom[1] = 32'b00000000011000000000011010010011; // addi x13, x0, 6
    rom[2] = 32'b00000000110101100000011100110011; // add  x14, x12, x13
    rom[3] = 32'b01000000110101110000011110110011; // sub  x15, x14, x13
    rom[4] = 32'b00000000100000000000100000010011; // addi x16, x0, 8
    rom[5] = 32'b00000001000010000000100010110011; // add  x17, x16, x16
    rom[6] = 32'b11111110000000000000000001101111; // jal  x0, -32 (loop back to start)
  end

  always_ff @(posedge clk) begin
    if (en)
      instr <= rom[widx];
  end
endmodule
