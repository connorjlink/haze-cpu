// haze-cpu: extender_NtoM.sv
// (c) 2026 Connor J. Link. All rights reserved.

module extender_NtoM
#(
    parameter int p_N = 12, // Input width
    parameter int p_M = 32  // Output width
) 
(
    input  logic [p_N-1:0] i_D,
    input  logic i_ExtensionType, // 0: zero-extend, 1: sign-extend
    output logic [p_M-1:0] o_Q
);

    logic [p_M-1:0] s_Rz;
    logic [p_M-1:0] s_Rs;

    // Zero-extend
    assign s_Rz = {{(p_M-p_N){1'b0}}, i_D};

    // Sign-extend (duplicate most significant bit of the input i_D)
    assign s_Rs = {{(p_M-p_N){i_D[p_N-1]}}, i_D};

    assign o_Q = (i_ExtensionType == 1'b0) ? s_Rz : s_Rs;

endmodule