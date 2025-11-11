module gprs (
    input logic clk,
    input logic rst_n
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
    end
  end

  task read_register(input logic addr[4:0], output logic [31:0] data);
    data = registers[addr];
  endtask

  task write_register(input logic addr[4:0], input logic [31:0] data, input logic clk);
    always_ff @(posedge clk) begin
      if (addr != 5'b0) begin
        registers[addr] <= data;
      end
    end
  endtask
endmodule