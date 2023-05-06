// ============================================================================
// Module that calculates penalty given a start and end point
//=============================================================================

module reduction_calculator (
    input clk, 
    input reset,
    input [9:0] x0, y0, x1, y1,
    input [8:0] image_sram_in,
    input [3:0] weight_sram_in,
    output [18:0] reduction
)

