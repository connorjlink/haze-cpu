// haze-cpu: multiplexer_32to1.sv
// (c) 2025 Connor J. Link. All rights reserved.

module multiplexer_32to1
(
    input  logic [4:0]  i_S,
    input  logic [31:0] i_D [0:31],
    output logic [31:0] o_Q
);

    // Selection by index (equivalent to VHDL: i_D(to_integer(unsigned(i_S))))
    always_comb begin
        o_Q = i_D[i_S];
    end

endmodule