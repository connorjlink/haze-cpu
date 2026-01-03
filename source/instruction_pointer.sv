// haze-cpu: instruction_pointer.sv
// (c) 2026 Connor J. Link. All rights reserved.

module instruction_pointer #(
    // Default reset address (RARS data page)
    parameter logic [31:0] p_ResetAddress = 32'h0040_0000
) (
    input  logic        i_Clock,
    input  logic        i_Reset,
    input  logic        i_Load,
    input  logic [31:0] i_LoadAddress,
    input  logic        i_Stride, // 0: increment 2 bytes, 1: increment 4 bytes
    input  logic        i_Stall,
    output logic [31:0] o_MemoryAddress,
    output logic [31:0] o_LinkAddress
);

    logic        s_IPWriteEnable;
    logic [31:0] s_IPData;
    logic [31:0] s_IPAddress;
    logic [31:0] s_Stride;
    logic [31:0] s_LinkAddress;

    // Next data selection (synchronous reset via data mux)
    always_comb 
    begin
        s_IPData = i_Reset ? p_ResetAddress  :
                   i_Load  ? i_LoadAddress :
                            s_LinkAddress;

        // Upcounting is disabled when we need a pipeline stall, load overrides stall
        if (i_Load)       s_IPWriteEnable = 1'b1;
        else if (i_Stall) s_IPWriteEnable = 1'b0;
        else              s_IPWriteEnable = 1'b1;

        s_Stride = (i_Stride == 1'b0) ? 32'h0000_0002 : 32'h0000_0004;
    end

    // Instruction pointer register (no async reset)
    always_ff @(posedge i_Clock) 
    begin
        if (s_IPWriteEnable) 
        begin
            s_IPAddress <= s_IPData;
        end
    end

    assign s_LinkAddress = s_IPAddress + s_Stride;

    assign o_MemoryAddress = s_IPAddress;
    assign o_LinkAddress = s_LinkAddress;

endmodule