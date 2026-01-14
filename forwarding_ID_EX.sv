module forwarding_ID_EX (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall_in,
    
    // Data from EX stage (write-back candidate)
    input  logic [31:0] wb_data_in,
    input  logic [4:0]  wb_addr_in,
    input  logic        wb_valid_in,
    
    // Requested register addresses from ID stage
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    
    // Original register data from register file
    input  logic [31:0] rs1_data_rf,
    input  logic [31:0] rs2_data_rf,
    
    // Forwarded data outputs
    output logic [31:0] rs1_data_out,
    output logic [31:0] rs2_data_out,
    output logic        hazard_detected
);

    // Forwarding logic for rs1
    always_comb begin
        if (wb_valid_in && (wb_addr_in == rs1_addr) && (rs1_addr != 5'b0)) begin
            rs1_data_out = wb_data_in;  // Forward from EX stage
        end else begin
            rs1_data_out = rs1_data_rf; // Use register file data
        end
    end

    // Forwarding logic for rs2
    always_comb begin
        if (wb_valid_in && (wb_addr_in == rs2_addr) && (rs2_addr != 5'b0)) begin
            rs2_data_out = wb_data_in;  // Forward from EX stage
        end else begin
            rs2_data_out = rs2_data_rf; // Use register file data
        end
    end

    // Hazard detection (load-use hazard)
    // If we need data that's being loaded in the previous cycle, we need to stall
    assign hazard_detected = 1'b0; // Basic implementation; can be enhanced for load-use hazards

endmodule