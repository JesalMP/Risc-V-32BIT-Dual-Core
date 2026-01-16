`timescale 1ns / 1ps

module riscV(input logic clk,
               input logic rst_n);

  //Stall and hazard signals
  logic stall_pipeline;
  logic [1:0] forward_a, forward_b;
  logic branch_taken;
  logic flush_pipeline;

  // RISC-V implementation details would go here
  //IF
  logic [31:0] instr_from_IF;
  logic [31:0] pc_from_IF;

  //ID
  logic stall_from_ID;
  logic [6:0] opcode_from_ID;
  logic [31:0] rs1_data_from_ID;
  logic [31:0] rs2_data_from_ID;
  logic [31:0] pc_from_ID;
  logic [4:0] rs1_addr_from_ID;
  logic [4:0] rs2_addr_from_ID;
  logic [4:0] rd_addr_from_ID;
  logic [2:0] funct3_from_ID;
  logic [6:0] funct7_from_ID;
  logic [31:0] imm_from_ID;
  logic [31:0] imm_j_from_ID;
  logic RegWrite_from_ID;
  logic MemRead_from_ID;
  logic MemWrite_from_ID;
  logic MemtoReg_from_ID;
  logic ALUSrc_from_ID;
  logic [1:0] ALUOp_from_ID;
  logic Jump_from_ID;
  logic Branch_from_ID;

  //EX
  logic stall_from_EX;
  logic [31:0] alu_result_from_EX;
  logic [31:0] rs2_data_from_EX;
  logic [31:0] branch_target_from_EX;
  logic [4:0] rd_addr_from_EX;
  logic [2:0] funct3_from_EX;
  logic RegWrite_from_EX;
  logic MemRead_from_EX;
  logic MemWrite_from_EX;
  logic MemtoReg_from_EX;

  //MEM
  logic stall_from_MEM;
  logic [31:0] mem_data_from_MEM;
  logic [31:0] alu_result_from_MEM;
  logic [4:0] rd_addr_from_MEM;
  logic RegWrite_from_MEM;
  logic MemtoReg_from_MEM;

  //WB
  logic [31:0] wb_data;
  logic [4:0] wb_addr;
  logic wb_enable;

  // Flush pipeline on branch/jump taken
  assign flush_pipeline = branch_taken;

  // Hazard Detection Unit
  hazard_detection_unit hdu_inst (
      .id_rs1(rs1_addr_from_ID),
      .id_rs2(rs2_addr_from_ID),
      .ex_rd(rd_addr_from_EX),
      .ex_mem_read(MemRead_from_EX),
      .ex_reg_write(RegWrite_from_EX),
      .mem_rd(rd_addr_from_MEM),
      .mem_reg_write(RegWrite_from_MEM),
      .wb_rd(wb_addr),
      .wb_reg_write(wb_enable),
      .stall(stall_pipeline),
      .forward_a(forward_a),
      .forward_b(forward_b)
  );

  // Instruction Fetch (IF) stage
  IF if_stage (
      .clk(clk),
      .rst_n(rst_n),
      .branch_taken(branch_taken),
      .branch_target(branch_target_from_EX),
      .stall(stall_pipeline),
      .instr_out(instr_from_IF),
      .pc_out(pc_from_IF)
  );

  // Instruction Decode (ID) stage
  ID id_stage (
      .clk(clk),
      .rst_n(rst_n),
      .instr_in(instr_from_IF),
      .pc_in(pc_from_IF),
      .stall_in(stall_pipeline),
      .flush_in(flush_pipeline),
      .stall_out(stall_from_ID),
      .opcode_out(opcode_from_ID),
      .rs1_out(rs1_data_from_ID),
      .rs2_out(rs2_data_from_ID),
      .pc_out(pc_from_ID),
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
      .Jump(Jump_from_ID),
      .Branch(Branch_from_ID),
      .wb_data(wb_data),
      .wb_addr(wb_addr),
      .wb_enable(wb_enable),
      .rs1_addr_out(rs1_addr_from_ID),
      .rs2_addr_out(rs2_addr_from_ID)
  );

  // Execute (EX) stage
  EX ex_stage (
      .clk(clk),
      .rst_n(rst_n),
      .stall_in(stall_pipeline),
      .rs1_in(rs1_data_from_ID),
      .rs2_in(rs2_data_from_ID),
      .pc_in(pc_from_ID),
      .rd_addr_in(rd_addr_from_ID),
      .imm_in(imm_from_ID),
      .funct3_in(funct3_from_ID),
      .funct7_in(funct7_from_ID),
      .RegWrite_in(RegWrite_from_ID),
      .MemRead_in(MemRead_from_ID),
      .MemWrite_in(MemWrite_from_ID),
      .MemtoReg_in(MemtoReg_from_ID),
      .ALUSrc(ALUSrc_from_ID),
      .ALUOp(ALUOp_from_ID),
      .Jump(Jump_from_ID),
      .Branch(Branch_from_ID),
      .alu_result_out(alu_result_from_EX),
      .rs2_out(rs2_data_from_EX),
      .rd_addr_out(rd_addr_from_EX),
      .funct3_out(funct3_from_EX),
      .RegWrite_out(RegWrite_from_EX),
      .MemRead_out(MemRead_from_EX),
      .MemWrite_out(MemWrite_from_EX),
      .MemtoReg_out(MemtoReg_from_EX),
      .branch_target_out(branch_target_from_EX),
      .branch_taken_out(branch_taken),
      .stall_out(stall_from_EX)
  );

  // Memory (MEM) stage
  MEM mem_stage (
      .clk(clk),
      .rst_n(rst_n),
      .stall_in(1'b0),
      .alu_result_in(alu_result_from_EX),
      .rs2_in(rs2_data_from_EX),
      .rd_addr_in(rd_addr_from_EX),
      .funct3_in(funct3_from_EX),
      .RegWrite_in(RegWrite_from_EX),
      .MemRead_in(MemRead_from_EX),
      .MemWrite_in(MemWrite_from_EX),
      .MemtoReg_in(MemtoReg_from_EX),
      .mem_data_out(mem_data_from_MEM),
      .alu_result_out(alu_result_from_MEM),
      .rd_addr_out(rd_addr_from_MEM),
      .RegWrite_out(RegWrite_from_MEM),
      .MemtoReg_out(MemtoReg_from_MEM),
      .stall_out(stall_from_MEM)
  );

  // Write-back (WB) stage
  WB wb_stage (
      .clk(clk),
      .rst_n(rst_n),
      .mem_data_in(mem_data_from_MEM),
      .alu_result_in(alu_result_from_MEM),
      .rd_addr_in(rd_addr_from_MEM),
      .RegWrite_in(RegWrite_from_MEM),
      .MemtoReg_in(MemtoReg_from_MEM),
      .wb_data_out(wb_data),
      .wb_addr_out(wb_addr),
      .wb_enable_out(wb_enable)
  );

endmodule