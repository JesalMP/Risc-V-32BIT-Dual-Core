module riscV(input logic clk,
               input logic rst_n);

  //Stall initiators
  logic stall_from_ID=0;
  logic stall_from_EX=0;
  logic stall_from_MEM=0;

  // RISC-V implementation details would go here
  //IF
  logic [31:0] instr_from_IF;

  //ID
  //logic stall_out;
  logic [6:0] opcode_from_ID;
  logic [31:0] rs1_data_from_ID;
  logic [31:0] rs2_data_from_ID;
  logic [4:0] rd_addr_from_ID;
  logic [2:0] funct3_from_ID;
  logic [6:0] funct7_from_ID;
  logic [11:0] imm_from_ID;
  logic [19:0] imm_j_from_ID;
  logic RegWrite_from_ID;
  logic MemRead_from_ID;
  logic MemWrite_from_ID;
  logic MemtoReg_from_ID;
  logic ALUSrc_from_ID;
  logic [1:0] ALUOp_from_ID;
  logic Jump_from_ID;

  // Instruction Fetch (IF) stage
  IF if_stage (
      .clk(clk),
      .rst_n(rst_n),
      .instr_out(instr_from_IF)
  );

  // Instruction Decode (ID) stage
  ID id_stage (
      .clk(clk),
      .rst_n(rst_n),
      .instr_in(instr_from_IF),
      .stall_in(0), // No stall signal for now
      .stall_out(stall_from_ID), // Not connected for now
      .opcode_out(opcode_from_ID),
      .rs1_out(rs1_data_from_ID),
      .rs2_out(rs2_data_from_ID),
      .rd_addr_out(rd_addr_from_ID),
      .funct3_out(funct3_from_ID),
      .funct7_out(funct7_from_ID),
      .imm_out(imm_from_ID),
      .imm_j_out(imm_j_from_ID),
      .RegWrite(RegWrite_from_ID),
      .MemRead(MemRead_from_ID),
      .MemWrite(MemWrite_from_ID),
      .MemtoReg(MemtoReg_from_ID),
      .ALUSrc(ALUSrc_from_ID),
      .ALUOp(ALUOp_from_ID),
      .Jump(Jump_from_ID)
  );

endmodule