`timescale 1ns / 1ps

module imem_sync #(
  parameter IMEM_BYTES = 4096,
  localparam WORDS     = IMEM_BYTES/4,
  localparam AW        = $clog2(WORDS)
) (
  input  logic         clk,
  input  logic         en,           // fetch enable
  input  logic [31:0]  pc,           // byte address
  output logic [31:0]  instr         // valid next cycle when en=1
);
  wire [AW-1:0] widx = pc[AW+1:2];

  (* rom_style = "block" *) logic [31:0] rom [0:WORDS-1];

  initial begin
    //$readmemh("program.hex", rom);
    // Test program with branches and jumps
    rom[0] = 32'b00000000000100000000001100010011; // addi x6,  x0, 1
    rom[1] = 32'b00000000001000000000001110010011; // addi x7,  x0, 2
    rom[2] = 32'b00000000010100110000010000110011; // add  x8,  x6, x5
    rom[3] = 32'b00000000011000111000010010110011; // add  x9,  x7, x6
    rom[4] = 32'b00000000100101000000010100110011; // add  x10, x8, x9
    rom[5] = 32'b00000000011000111001010001100011; // bne  x7, x6, 8 (branch forward if x7 != x6)
    rom[6] = 32'b00000000000100000000010110010011; // addi x11, x0, 1 (skipped if branch taken)
    rom[7] = 32'b00000000001000000000011000010011; // addi x12, x0, 2 (target of branch)
    rom[8] = 32'b00000010000000000000000001101111; // jal  x0, 32 (jump forward to rom[16])
    rom[9] = 32'b00000000000000000000000000000000; // nop (skipped)
    rom[10] = 32'b00000000000000000000000000000000; // nop (skipped)
    rom[11] = 32'b00000000000000000000000000000000; // nop (skipped)
    rom[12] = 32'b00000000000000000000000000000000; // nop (skipped)
    rom[13] = 32'b00000000000000000000000000000000; // nop (skipped)
    rom[14] = 32'b00000000000000000000000000000000; // nop (skipped)
    rom[15] = 32'b00000000000000000000000000000000; // nop (skipped)
    rom[16] = 32'b00000000001100000000011010010011; // addi x13, x0, 3 (target of jal)
    rom[17] = 32'b11111110000000000000000001101111; // jal  x0, -32 (infinite loop back to rom[13])

  end

  always_ff @(posedge clk) begin
    if (en)
      instr <= rom[widx];   // registered read → 1-cycle latency
  end
endmodule
