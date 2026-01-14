`timescale 1ns / 1ps

module gprs (
    input logic clk,
    input logic rst_n,
    input logic we,              // write enable
    input logic [4:0] waddr,     // write address
    input logic [31:0] wdata,    // write data
    input logic [4:0] raddr1,    // read address 1
    input logic [4:0] raddr2,    // read address 2
    output logic [31:0] rdata1,  // read data 1
    output logic [31:0] rdata2   // read data 2
);

  // Register file with 32 registers of 32 bits each
  logic [31:0] registers [0:31];

  // Write data to register on the rising edge of the clock
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset all registers to zero
      integer i;
      for (i = 0; i < 32; i = i + 1) begin
        registers[i] <= 32'b0;
      end
    end else begin
      // Write to register (x0 is hardwired to 0)
      if (we && waddr != 5'b0) begin
        registers[waddr] <= wdata;
      end
    end
  end

  // Combinational read (2 read ports)
  assign rdata1 = registers[raddr1];
  assign rdata2 = registers[raddr2];

endmodule