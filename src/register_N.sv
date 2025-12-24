// haze-cpu: register_N.sv
// (c) 2025 Connor J. Link. All rights reserved.

module register_N #(parameter int N = 32)
(
    input  logic             i_Clock,  
    input  logic             i_Reset,  
    input  logic             i_WriteEnable,
    input  logic [N-1:0]     i_D,
    output logic [N-1:0]     o_Q
);

    always_ff @(posedge i_Clock or posedge i_Reset) begin
        if (i_Reset) begin
            o_Q <= '0;
        end else if (i_WriteEnable) begin
            o_Q <= i_D;
        end
    end

endmodule