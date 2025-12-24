// haze-cpu: set_less.sv
// (c) 2025 Connor J. Link. All rights reserved.

module set_less 
(
    input  logic [31:0] i_A,
    input  logic [31:0] i_B,
    output logic [31:0] o_Less,
    output logic [31:0] o_LessUnsigned
);

    // Unsigned comparison
    assign o_LessUnsigned = (i_A < i_B) ? 32'h0000_0001 : 32'h0000_0000;

    // Signed compare
    assign o_Less  = ($signed(i_A) < $signed(i_B)) ? 32'h0000_0001 : 32'h0000_0000;

endmodule
