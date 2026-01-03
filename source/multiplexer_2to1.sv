// haze-cpu: multiplexer_2to1.sv
// (c) 2026 Connor J. Link. All rights reserved.

module multiplexer_2to1 
(
    input  logic i_D0,
    input  logic i_D1,
    input  logic i_S,
    output logic o_O
);
    // equivalent to "a ? b : c"
    always_comb begin
        unique case (i_S)
            1'b0:    o_O = i_D0;
            1'b1:    o_O = i_D1;
            default: o_O = 1'bx; // fallback for simulation purposes
        endcase
    end

endmodule