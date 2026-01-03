// haze-cpu: fulladder_N.sv
// (c) 2026 Connor J. Link. All rights reserved.

`include "full_adder.sv"

module fulladder_N #(parameter int N = 32)
(
    input  logic [N-1:0] i_A,
    input  logic [N-1:0] i_B,
    input  logic         i_CarryIn,
    output logic [N-1:0] o_S,
    output logic         o_CarryOut
);

    logic [N:0] s_CarryIntermediate;

    assign s_CarryIntermediate[0] = i_CarryIn;
    assign o_CarryOut = s_CarryIntermediate[N];

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : g_NBit_Adder
            full_adder u_full_adder
            (
                .i_A        (i_A[i]),
                .i_B        (i_B[i]),
                .i_CarryIn  (s_CarryIntermediate[i]),
                .o_S        (o_S[i]),
                .o_CarryOut (s_CarryIntermediate[i+1])
            );
        end
    endgenerate

endmodule