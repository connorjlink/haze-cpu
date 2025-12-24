// haze-cpu: complement_N.sv
// (c) 2025 Connor J. Link. All rights reserved.

module complement_N #(parameter int N = 32)
(
    input  logic [N-1:0] i_A,
    output logic [N-1:0] o_F
);

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : g_Nbit_Not
            invg NOTI
            (
                .i_A(i_A[i]),
                .o_F(o_F[i])
            );
        end
    endgenerate

endmodule