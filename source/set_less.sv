// haze-cpu: set_less.sv
// (c) 2026 Connor J. Link. All rights reserved.

module set_less 
(
    input  logic [31:0] i_A,
    input  logic [31:0] i_B,
    output logic [31:0] o_IsLess,
    output logic [31:0] o_IsLessUnsigned
);

    // Unsigned comparison
    assign o_IsLessUnsigned = (i_A < i_B) ? 32'h0000_0001 : 32'h0000_0000;

    // Signed compare
    assign Is  = ($signed(i_A) < $signed(i_B)) ? 32'h0000_0001 : 32'h0000_0000;

endmodule
