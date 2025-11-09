module ID (
    input logic clk,
    input logic rst_n,
    input logic [31:0] instr_in,
    input logic stall_in = 0,
    output logic stall_out,
    output logic [6:0] opcode_out,
    output logic [4:0] rs1_out,
    output logic [4:0] rs2_out,
    output logic [4:0] rd_out,
    output logic [2:0] funct3_out,
    output logic [6:0] funct7_out,
    output logic [11:0] imm_out,
    output logic [19:0] imm_j_out
);
    logic stall;
    logic [6:0] opcode;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] imm;
    logic [19:0] imm_j;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stall_out <= 1'b0;
            opcode_out <= 7'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
            funct3_out <= 3'b0;
            funct7_out <= 7'b0;
            imm_out <= 12'b0;
            imm_j_out <= 20'b0;
        end
        if (stall_in) begin
            stall_out <= 1'b1; // Hold the instruction if stalled
            opcode_out <= opcode_out;
            rs1_out <= rs1_out;
            rs2_out <= rs2_out;
            rd_out <= rd_out;
            funct3_out <= funct3_out;
            funct7_out <= funct7_out;
            imm_out <= imm_out;
            imm_j_out <= imm_j_out;
            $strobe("ID Stage - Stalled Instruction: %0b", instr_in);
        end else begin
            stall_out <= 1'b0;
            opcode_out <= instr_in[6:0];
            case (instr_in[6:0])
                 // ---------------- R-type ----------------
                7'b0110011: begin
                    rd_out     <= instr_in[11:7];
                    funct3_out <= instr_in[14:12];
                    funct7_out <= instr_in[31:25];
                    rs1_out    <= instr_in[19:15];
                    rs2_out    <= instr_in[24:20];
                    $strobe("ID Stage - R-type: %0b", instr_in);
                end

                // ---------------- I-type (ADDI, LW, JALR) ----------------
                7'b0010011, // arithmetic immediate
                7'b0000011, // load
                7'b1100111: // JALR
                begin
                    rd_out     <= instr_in[11:7];
                    funct3_out <= instr_in[14:12];
                    rs1_out    <= instr_in[19:15];
                    imm_out    <= {{20{instr_in[31]}}, instr_in[31:20]}; // sign-extended
                    $strobe("ID Stage - I-type: %0b", instr_in);
                end

                // ---------------- S-type (Store) ----------------
                7'b0100011: begin
                    funct3_out <= instr_in[14:12];
                    rs1_out    <= instr_in[19:15];
                    rs2_out    <= instr_in[24:20];
                    imm_out    <= {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]};
                    $strobe("ID Stage - S-type: %0b", instr_in);
                end

                // ---------------- J-type (JAL) ----------------
                7'b1101111: begin
                    rd_out    <= instr_in[11:7];
                    imm_j_out <= {{11{instr_in[31]}}, instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
                    $strobe("ID Stage - J-type: %0b", instr_in);
                end

                // ---------------- Default ----------------
                default: begin
                    rd_out     <= 5'b0;
                    funct3_out <= 3'b0;
                    funct7_out <= 7'b0;
                    rs1_out    <= 5'b0;
                    rs2_out    <= 5'b0;
                    imm_out    <= 32'b0;
                    imm_j_out  <= 32'b0;
                    $strobe("ID Stage - Unknown: %0b", instr_in);
                end
            endcase
        end
    end
endmodule