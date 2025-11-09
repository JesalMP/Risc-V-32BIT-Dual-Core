module control_unit(
    input  [6:0] opcode,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg ALUSrc,
    output reg [1:0] ALUOp,
    output reg Jump
);
always @(*) begin
    RegWrite = 0; MemRead = 0; MemWrite = 0;
    MemtoReg = 0; ALUSrc = 0; ALUOp = 2'b00; Jump = 0;

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
        7'b1101111: begin // JAL
            RegWrite = 1; Jump = 1; ALUOp = 2'b00;
        end
        default: begin
            // do nothing
        end
    endcase
end
endmodule
