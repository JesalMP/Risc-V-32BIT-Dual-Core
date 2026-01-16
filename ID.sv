`timescale 1ns / 1ps

module ID (
    input logic clk,
    input logic rst_n,
    input logic [31:0] instr_in,
    input logic [31:0] pc_in,
    input logic stall_in = 0,
    input logic flush_in = 0,
    output logic stall_out,
    output logic [6:0] opcode_out,
    output logic [31:0] rs1_out,
    output logic [31:0] rs2_out,
    output logic [31:0] pc_out,
    output logic [4:0] rd_addr_out,
    output logic [2:0] funct3_out,
    output logic [6:0] funct7_out,
    output logic [31:0] imm_out,
    output logic [31:0] imm_j_out,
    output logic RegWrite,
    output logic MemRead,
    output logic MemWrite,
    output logic MemtoReg,
    output logic ALUSrc,
    output logic [1:0] ALUOp,
    output logic Jump,
    output logic Branch,
    
    // Write-back signals
    input logic [31:0] wb_data,
    input logic [4:0] wb_addr,
    input logic wb_enable,
    
    // Register address outputs for hazard detection
    output logic [4:0] rs1_addr_out,
    output logic [4:0] rs2_addr_out
);  
    control_unit cu_inst (
        .opcode(instr_in[6:0]),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .Jump(Jump),
        .Branch(Branch)
    );

    logic [4:0] rs1_addr, rs2_addr;
    logic [31:0] rs1_data, rs2_data;

    gprs gprs_inst (
        .clk(clk),
        .rst_n(rst_n),
        .we(wb_enable),
        .waddr(wb_addr),
        .wdata(wb_data),
        .raddr1(rs1_addr),
        .raddr2(rs2_addr),
        .rdata1(rs1_data),
        .rdata2(rs2_data)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stall_out <= 1'b0;
            opcode_out <= 7'b0;
            rs1_out <= 32'b0;
            rs2_out <= 32'b0;
            pc_out <= 32'b0;
            rd_addr_out <= 5'b0;
            funct3_out <= 3'b0;
            funct7_out <= 7'b0;
            imm_out <= 32'b0;
            imm_j_out <= 32'b0;
        end
        if (flush_in) begin
            // Insert NOP (bubble) into pipeline
            stall_out <= 1'b0;
            opcode_out <= 7'b0;
            rs1_out <= 32'b0;
            rs2_out <= 32'b0;
            rd_addr_out <= 5'b0;
            funct3_out <= 3'b0;
            funct7_out <= 7'b0;
            imm_out <= 32'b0;
            imm_j_out <= 32'b0;
            pc_out <= 32'b0;
        end else if (stall_in) begin
            stall_out <= 1'b1; // Hold the instruction if stalled
            opcode_out <= opcode_out;
            rs1_out <= rs1_out;
            rs2_out <= rs2_out;
            rd_addr_out <= rd_addr_out;
            funct3_out <= funct3_out;
            funct7_out <= funct7_out;
            imm_out <= imm_out;
            imm_j_out <= imm_j_out;
            $strobe("ID Stage - Stalled Instruction: %0b", instr_in);
        end else begin
            stall_out <= 1'b0;
            opcode_out <= instr_in[6:0];
            pc_out <= pc_in;
            rs1_addr_out <= rs1_addr;
            rs2_addr_out <= rs2_addr;
            case (instr_in[6:0])
                 // ---------------- R-type ----------------
                7'b0110011: begin
                    rd_addr_out <= instr_in[11:7];
                    funct3_out <= instr_in[14:12];
                    funct7_out <= instr_in[31:25];
                    rs1_addr = instr_in[19:15];
                    rs2_addr = instr_in[24:20];
                    rs1_out <= rs1_data;
                    rs2_out <= rs2_data;
                    $strobe("ID Stage - R-type: %032b", instr_in);
                end

                // ---------------- I-type (ADDI, LW, JALR) ----------------
                7'b0010011, // arithmetic immediate
                7'b0000011, // load
                7'b1100111: // JALR
                begin
                    rd_addr_out <= instr_in[11:7];
                    funct3_out <= instr_in[14:12];
                    rs1_addr = instr_in[19:15];
                    rs2_addr = 5'b0;
                    rs1_out <= rs1_data;
                    rs2_out <= 32'b0;
                    imm_out <= {{20{instr_in[31]}}, instr_in[31:20]}; // sign-extended
                    $strobe("ID Stage - I-type: %032b", instr_in);
                end

                // ---------------- S-type (Store) ----------------
                7'b0100011: begin
                    funct3_out <= instr_in[14:12];
                    rs1_addr = instr_in[19:15];
                    rs2_addr = instr_in[24:20];
                    rs1_out <= rs1_data;
                    rs2_out <= rs2_data;
                    imm_out <= {{20{instr_in[31]}}, instr_in[31:25], instr_in[11:7]}; // sign-extended
                    $strobe("ID Stage - S-type: %032b", instr_in);
                end

                // ---------------- B-type (Branch) ----------------
                7'b1100011: begin
                    funct3_out <= instr_in[14:12];
                    rs1_addr = instr_in[19:15];
                    rs2_addr = instr_in[24:20];
                    rs1_out <= rs1_data;
                    rs2_out <= rs2_data;
                    imm_out <= {{20{instr_in[31]}}, instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0}; // sign-extended branch offset
                    $strobe("ID Stage - B-type: %032b", instr_in);
                end

                // ---------------- J-type (JAL) ----------------
                7'b1101111: begin
                    rd_addr_out <= instr_in[11:7];
                    rs1_addr = 5'b0;
                    rs2_addr = 5'b0;
                    rs1_out <= 32'b0;
                    rs2_out <= 32'b0;
                    imm_j_out <= {{11{instr_in[31]}}, instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0}; // sign-extended with 0 LSB
                    $strobe("ID Stage - J-type: %032b", instr_in);
                end

                // ---------------- Default ----------------
                default: begin
                    rd_addr_out <= 5'b0;
                    funct3_out <= 3'b0;
                    funct7_out <= 7'b0;
                    rs1_out <= 32'b0;
                    rs2_out <= 32'b0;
                    imm_out <= 32'b0;
                    imm_j_out <= 32'b0;
                    $strobe("ID Stage - Unknown: %032b", instr_in);
                end
            endcase
        end
    end
endmodule