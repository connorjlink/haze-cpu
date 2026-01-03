// haze-cpu: instruction_decoder.sv
// (c) 2026 Connor J. Link. All rights reserved.

module instruction_decoder
(
    input  logic [31:0]  i_Instruction,

    output logic [6:0]   o_Opcode,
    output logic [4:0]   o_RD,
    output logic [4:0]   o_RS1,
    output logic [4:0]   o_RS2,
    output logic [2:0]   o_Func3,
    output logic [6:0]   o_Func7,
    output logic [11:0]  o_iImm,
    output logic [11:0]  o_sImm,
    output logic [12:0]  o_bImm,
    output logic [31:12] o_uImm,
    output logic [20:0]  o_jImm,
    output logic [4:0]   o_hImm
);

    // Opcode field
    assign o_Opcode = i_Instruction[6:0];

    // Destination and both source register fields
    assign o_RD  = i_Instruction[11:7];
    assign o_RS1 = i_Instruction[19:15];
    assign o_RS2 = i_Instruction[24:20];

    // shamt field is in the same position as RS2
    // Shift immediate field
    assign o_hImm = i_Instruction[24:20];

    // Function fields
    assign o_Func3 = i_Instruction[14:12];
    assign o_Func7 = i_Instruction[31:25];

    // I-type immediate field
    assign o_iImm = i_Instruction[31:20];

    // S-type immediate field
    assign o_sImm[11:5] = i_Instruction[31:25];
    assign o_sImm[4:0]  = i_Instruction[11:7];

    // B-type immediate fields
    assign o_bImm[12]   = i_Instruction[31];
    assign o_bImm[11]   = i_Instruction[7];
    assign o_bImm[10:5] = i_Instruction[30:25];
    assign o_bImm[4:1]  = i_Instruction[11:8];
    assign o_bImm[0]    = 1'b0;

    // U-type immediate field
    assign o_uImm = i_Instruction[31:12];

    // J-type immediate fields
    assign o_jImm[20]   = i_Instruction[31];
    assign o_jImm[19:12]= i_Instruction[19:12];
    assign o_jImm[11]   = i_Instruction[20];
    assign o_jImm[10:1] = i_Instruction[30:21];
    assign o_jImm[0]    = 1'b0;

endmodule