module top;
 timeunit 1ns;
  timeprecision 1ns;
  
  logic clk=0;
  logic rst_n=1;
  
  always #5 clk = ~clk;
  riscV riscV_inst (
      .clk(clk),
      .rst_n(rst_n)
  );


endmodule