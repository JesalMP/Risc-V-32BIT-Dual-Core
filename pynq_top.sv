`timescale 1ns / 1ps

module pynq_top(
    input logic sysclk,   // 125 MHz system clock
    input logic btn0,     // Reset button
    output logic [3:0] led // 4 LEDs on the board
);

    // Clock divider: 125 MHz -> 31.25 MHz (divide by 4)
    logic [1:0] clk_div = 0;
    logic core_clk;
    
    always_ff @(posedge sysclk) begin
        clk_div <= clk_div + 1;
    end
    
    // Use the MSB of the divider as the core clock
    // Note: In a production design, it is recommended to use an MMCM/PLL or a BUFG
    // for clock generation to ensure proper clock routing.
    assign core_clk = clk_div[1];

    // Active-high to Active-low reset conversion
    // Assuming btn0 is unpressed=0, pressed=1
    logic rst_n;
    assign rst_n = ~btn0;
    
    // Core outputs
    logic [31:0] debug_out;

    // Instantiate the dual-core RISC-V processor
    dual_core_riscv processor_inst (
        .clk(core_clk),
        .rst_n(rst_n),
        .debug_out(debug_out)
    );
    
    // Map the lower 4 bits of the debug output to the LEDs
    assign led = debug_out[3:0];

endmodule
