module IF (
    input logic clk,
    input logic rst_n,
    output logic [31:0] instr_out
);

  // Instantiate instruction memory
  logic [31:0] instr_from_IF;
  logic [31:0] pc;
  logic [31:0] pc_to_IMEM;
  
  initial begin
    pc = 32'b0; // Initialize program counter
  end

  imem_sync imem_inst (
      .clk(clk),
      .en(1'b1),          // Always enable for instruction fetch
      .pc(pc_to_IMEM),
      .instr(instr_from_IF)
  );


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc <= 32'b0; // Reset program counter
      instr_out <= 32'b0; // Reset instruction output
    end else begin
      pc_to_IMEM <= pc; // Update PC for instruction memory
      instr_out <= instr_from_IF; // Output the fetched instruction
        pc <= pc + 4; // Increment program counter
    end
    $strobe("IF Stage - PC: %0b, Instruction: %b", pc, instr_from_IF);
  end
  
endmodule