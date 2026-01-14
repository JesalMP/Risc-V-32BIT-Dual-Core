`timescale 1ns / 1ps

module EX (
    input logic clk,
    input logic rst_n,
    input logic stall_in = 0,
    
    // Data inputs
    input logic [31:0] rs1_in,
    input logic [31:0] rs2_in,
    input logic [4:0] rd_addr_in,
    input logic [31:0] imm_in,
    input logic [2:0] funct3_in,
    input logic [6:0] funct7_in,
    
    // Control signals
    input logic RegWrite_in,
    input logic MemRead_in,
    input logic MemWrite_in,
    input logic MemtoReg_in,
    input logic ALUSrc,
    input logic [1:0] ALUOp,
    input logic Jump,
    
    // Outputs
    output logic [31:0] alu_result_out,
    output logic [31:0] rs2_out,
    output logic [4:0] rd_addr_out,
    output logic [2:0] funct3_out,
    output logic RegWrite_out,
    output logic MemRead_out,
    output logic MemWrite_out,
    output logic MemtoReg_out,
    output logic stall_out
);

    // Internal signals
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic [3:0] alu_control;
    logic alu_zero;
    
    // ALU operand selection
    assign alu_operand_a = rs1_in;
    assign alu_operand_b = ALUSrc ? imm_in : rs2_in;
    
    // ALU Control generation based on ALUOp and funct fields
    always_comb begin
        case (ALUOp)
            2'b00: alu_control = 4'b0010; // ADD (for load/store)
            2'b01: alu_control = 4'b0110; // SUB (for branches)
            2'b10: begin // R-type or I-type arithmetic
                case (funct3_in)
                    3'b000: begin
                        if (funct7_in[5] && !ALUSrc) // SUB (R-type only)
                            alu_control = 4'b0110;
                        else // ADD/ADDI
                            alu_control = 4'b0010;
                    end
                    3'b001: alu_control = 4'b0011; // SLL/SLLI
                    3'b010: alu_control = 4'b0111; // SLT/SLTI
                    3'b011: alu_control = 4'b1000; // SLTU/SLTIU
                    3'b100: alu_control = 4'b0100; // XOR/XORI
                    3'b101: begin
                        if (funct7_in[5]) // SRA/SRAI
                            alu_control = 4'b1001;
                        else // SRL/SRLI
                            alu_control = 4'b0101;
                    end
                    3'b110: alu_control = 4'b0001; // OR/ORI
                    3'b111: alu_control = 4'b0000; // AND/ANDI
                    default: alu_control = 4'b0010; // Default to ADD
                endcase
            end
            default: alu_control = 4'b0010; // Default to ADD
        endcase
    end
    
    // ALU instantiation
    ALU alu_inst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );
    
    // Pipeline registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_result_out <= 32'b0;
            rs2_out <= 32'b0;
            rd_addr_out <= 5'b0;
            funct3_out <= 3'b0;
            RegWrite_out <= 1'b0;
            MemRead_out <= 1'b0;
            MemWrite_out <= 1'b0;
            MemtoReg_out <= 1'b0;
            stall_out <= 1'b0;
        end else if (stall_in) begin
            // Hold current values if stalled
            stall_out <= 1'b1;
        end else begin
            alu_result_out <= alu_result;
            rs2_out <= rs2_in; // Pass rs2 for store operations
            rd_addr_out <= rd_addr_in;
            funct3_out <= funct3_in;
            RegWrite_out <= RegWrite_in;
            MemRead_out <= MemRead_in;
            MemWrite_out <= MemWrite_in;
            MemtoReg_out <= MemtoReg_in;
            stall_out <= 1'b0;
            
            $strobe("EX Stage - ALU: %08h = %08h op %08h | RD: x%0d | Ctrl: RegWr=%b MemRd=%b MemWr=%b", 
                    alu_result, alu_operand_a, alu_operand_b, rd_addr_in, RegWrite_in, MemRead_in, MemWrite_in);
        end
    end

endmodule