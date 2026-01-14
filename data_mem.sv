`timescale 1ns / 1ps

module data_mem #(
    parameter DMEM_BYTES = 4096,
    localparam WORDS = DMEM_BYTES/4,
    localparam AW = $clog2(WORDS)
) (
    input logic clk,
    input logic rst_n,
    input logic mem_read,
    input logic mem_write,
    input logic [31:0] address,      // byte address
    input logic [31:0] write_data,
    input logic [2:0] funct3,        // for byte/half/word access
    output logic [31:0] read_data
);

    wire [AW-1:0] word_addr = address[AW+1:2];
    logic [31:0] mem [0:WORDS-1];
    
    // Initialize memory to zero
    initial begin
        integer i;
        for (i = 0; i < WORDS; i = i + 1) begin
            mem[i] = 32'b0;
        end
    end
    
    // Synchronous read/write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            case (funct3[1:0])
                2'b00: begin // SB - store byte
                    case (address[1:0])
                        2'b00: mem[word_addr][7:0]   <= write_data[7:0];
                        2'b01: mem[word_addr][15:8]  <= write_data[7:0];
                        2'b10: mem[word_addr][23:16] <= write_data[7:0];
                        2'b11: mem[word_addr][31:24] <= write_data[7:0];
                    endcase
                end
                2'b01: begin // SH - store half
                    if (address[1] == 0)
                        mem[word_addr][15:0]  <= write_data[15:0];
                    else
                        mem[word_addr][31:16] <= write_data[15:0];
                end
                2'b10: begin // SW - store word
                    mem[word_addr] <= write_data;
                end
                default: mem[word_addr] <= write_data;
            endcase
        end
        
        if (mem_read) begin
            case (funct3)
                3'b000: begin // LB - load byte (sign-extended)
                    case (address[1:0])
                        2'b00: read_data <= {{24{mem[word_addr][7]}},  mem[word_addr][7:0]};
                        2'b01: read_data <= {{24{mem[word_addr][15]}}, mem[word_addr][15:8]};
                        2'b10: read_data <= {{24{mem[word_addr][23]}}, mem[word_addr][23:16]};
                        2'b11: read_data <= {{24{mem[word_addr][31]}}, mem[word_addr][31:24]};
                    endcase
                end
                3'b001: begin // LH - load half (sign-extended)
                    if (address[1] == 0)
                        read_data <= {{16{mem[word_addr][15]}}, mem[word_addr][15:0]};
                    else
                        read_data <= {{16{mem[word_addr][31]}}, mem[word_addr][31:16]};
                end
                3'b010: begin // LW - load word
                    read_data <= mem[word_addr];
                end
                3'b100: begin // LBU - load byte unsigned
                    case (address[1:0])
                        2'b00: read_data <= {24'b0, mem[word_addr][7:0]};
                        2'b01: read_data <= {24'b0, mem[word_addr][15:8]};
                        2'b10: read_data <= {24'b0, mem[word_addr][23:16]};
                        2'b11: read_data <= {24'b0, mem[word_addr][31:24]};
                    endcase
                end
                3'b101: begin // LHU - load half unsigned
                    if (address[1] == 0)
                        read_data <= {16'b0, mem[word_addr][15:0]};
                    else
                        read_data <= {16'b0, mem[word_addr][31:16]};
                end
                default: read_data <= mem[word_addr];
            endcase
        end
    end

endmodule
