// haze-cpu: extender_NtoM.sv
// (c) 2025 Connor J. Link. All rights reserved.

module extender_NtoM
#(
    parameter int N = 12, // Input width
    parameter int M = 32  // Output width
) 
(
    input  logic [N-1:0] i_D,
    input  logic i_ExtensionType, // 0: zero-extend, 1: sign-extend
    output logic [M-1:0] o_Q
);

    logic [M-1:0] s_Rz;
    logic [M-1:0] s_Rs;

    // Zero-extend
    assign s_Rz = {{(M-N){1'b0}}, i_D};

    // Sign-extend (duplicate most significant bit of the input i_D)
    assign s_Rs = {{(M-N){i_D[N-1]}}, i_D};

    // "Multiplex" the result
    assign o_Q = (i_ExtensionType == 1'b0) ? s_Rz : s_Rs;

endmodule