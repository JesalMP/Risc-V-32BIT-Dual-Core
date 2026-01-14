`timescale 1ns / 1ps

module top;
  timeunit 1ns;
  timeprecision 1ns;
  
  logic clk=0;
  logic rst_n=0;
  
  // Clock generation
  always #5 clk = ~clk;
  
  // Reset sequence
  initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
    #300;  // Run for 300ns (30 clock cycles)
    $display("Simulation finished");
    $finish;
  end
  
  riscV riscV_inst (
      .clk(clk),
      .rst_n(rst_n)
  );

endmodule