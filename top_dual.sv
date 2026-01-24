`timescale 1ns / 1ps

module top_dual;
  timeunit 1ns;
  timeprecision 1ns;
  
  logic clk=0;
  logic rst_n=0;
  
  // Clock generation (100MHz)
  always #5 clk = ~clk;
  
  // Reset sequence
  initial begin
    $display("\n==== Starting Dual-Core RISC-V Simulation ====\n");
    rst_n = 0;
    #20;
    rst_n = 1;
    $display("Reset released at time %0t", $time);
    #500;  // Run for 500ns (50 clock cycles) to see both cores executing
    $display("\n==== Simulation finished at time %0t ====", $time);
    $finish;
  end
  
  dual_core_riscv dual_core_inst (
      .clk(clk),
      .rst_n(rst_n)
  );

endmodule
