// ============================================================================
// Module that calculates penalty given a start and end point
//=============================================================================

module reduction_calculator (
    input signed [8:0] image_data,
    input [3:0] weight_data,
    output logic signed [15:0] reduction
);

logic signed [15:0] penalty_before;
logic signed [15:0] penalty_after;
logic signed [15:0] image_data_sext;

assign image_data_sext = { {7{image_data[8]}}, image_data };

logic signed [15:0] image_value_after;

assign image_value_after = image_data_sext - 16'sd150;
assign reduction = penalty_before - penalty_after;

always_comb begin
    if ( image_data < 0 ) begin 
        penalty_before = -image_data_sext>>>1; // 1 is the lightness penalty
    end 
    else begin 
        penalty_before = image_data_sext; // 1 is the lightness penalty
    end 
    if ( image_value_after < 0 ) begin 
        penalty_after = -image_value_after>>>1; // 1 is the lightness penalty
    end 
    else begin 
        penalty_after = image_value_after; // 1 is the lightness penalty
    end
end

endmodule

