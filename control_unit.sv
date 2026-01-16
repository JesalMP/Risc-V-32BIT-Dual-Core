`timescale 1ns / 1ps

module control_unit(
    input  logic [6:0] opcode,
    output logic RegWrite,
    output logic MemRead,
    output logic MemWrite,
    output logic MemtoReg,
    output logic ALUSrc,
    output logic [1:0] ALUOp,
    output logic Jump,
    output logic Branch
);
always @(*) begin
    RegWrite = 0; MemRead = 0; MemWrite = 0;
    MemtoReg = 0; ALUSrc = 0; ALUOp = 2'b00; Jump = 0; Branch = 0;

    case (opcode)
        7'b0110011: begin // R-type
            RegWrite = 1; ALUOp = 2'b10;
        end
        7'b0010011: begin // I-type arithmetic
            RegWrite = 1; ALUSrc = 1; ALUOp = 2'b10;
        end
        7'b0000011: begin // LW
            RegWrite = 1; MemRead = 1; MemtoReg = 1;
            ALUSrc = 1; ALUOp = 2'b00;
        end
        7'b0100011: begin // SW
            MemWrite = 1; ALUSrc = 1; ALUOp = 2'b00;
        end
        7'b1100011: begin // Branch (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            Branch = 1; ALUOp = 2'b01;
        end
        7'b1101111: begin // JAL
            RegWrite = 1; Jump = 1; ALUOp = 2'b00;
        end
        7'b1100111: begin // JALR
            RegWrite = 1; Jump = 1; ALUSrc = 1; ALUOp = 2'b00;
        end
        default: begin
            // do nothing
        end
    endcase
end
endmodule
