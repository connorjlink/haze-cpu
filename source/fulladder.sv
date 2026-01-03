// haze-cpu: fulladder.sv
// (c) 2026 Connor J. Link. All rights reserved.

module fulladder
(
    input  logic i_A,
    input  logic i_B,
    input  logic i_CarryIn,
    output logic o_S,
    output logic o_CarryOut
);

	assign o_S  = i_A ^ i_B ^ i_CarryIn;
	assign o_CarryOut = (i_A & i_B) | (i_CarryIn & (i_A ^ i_B));

endmodule