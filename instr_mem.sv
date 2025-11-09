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
    rom[0] = 32'b00000000000100000000001100010011; // addi x6,  x0, 1
    rom[1] = 32'b00000000001000000000001110010011; // addi x7,  x0, 2
    rom[2] = 32'b00000000010100110000010000110011; // add  x8,  x6, x5
    rom[3] = 32'b00000000011000111000010010110011; // add  x9,  x7, x6
    rom[4] = 32'b01000000101001001000010000110011; // sub  x10, x8, x9

  end

  always_ff @(posedge clk) begin
    if (en)
      instr <= rom[widx];   // registered read → 1-cycle latency
  end
endmodule
