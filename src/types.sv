// haze-cpu: types.sv
// (c) 2025 Connor J. Link. All rights reserved.

package types;

  // Generic bit widths (note 10-bit used for 1K words of memory for now - 4 KiB)
  parameter int unsigned DATA_WIDTH = 32;
  parameter int unsigned ADDR_WIDTH = 10;

  // Common data word type
  typedef logic [31:0] word_t;

  // Type declaration for the register file storage
  // VHDL: type array_t is array (natural range <>) of std_logic_vector(31 downto 0);
  // SV equivalent: unsized unpacked array of 32-bit words (size provided where used)
  typedef word_t array_t[];

  // Corresponding func3 values for each branch type
  localparam int unsigned BEQ  = 1;
  localparam int unsigned BNE  = 2;
  localparam int unsigned BLT  = 3;
  localparam int unsigned BGE  = 4;
  localparam int unsigned BLTU = 5;
  localparam int unsigned BGEU = 6;
  localparam int unsigned J    = 7; // force jump for `jal` and `jalr`

  // Corresponding to each load/store data width
  localparam int unsigned BYTE   = 1;
  localparam int unsigned HALF   = 2;
  localparam int unsigned WORD   = 3;
  localparam int unsigned DOUBLE = 4;

  // Corresponding to each ALU operation code input signal
  localparam int unsigned ADD  = 0;
  localparam int unsigned SUB  = 1;
  localparam int unsigned BAND = 2;
  localparam int unsigned BOR  = 3;
  localparam int unsigned BXOR = 4;
  localparam int unsigned BSLL = 5;
  localparam int unsigned BSRL = 6;
  localparam int unsigned BSRA = 7;
  localparam int unsigned SLT  = 8;
  localparam int unsigned SLTU = 9;

  // Corresponding to each ALU source
  localparam int unsigned ALUSRC_REG    = 1;
  localparam int unsigned ALUSRC_IMM    = 2;
  localparam int unsigned ALUSRC_BIGIMM = 3;

  // Corresponding to each RF source command
  localparam int unsigned FROM_RAM    = 1;
  localparam int unsigned FROM_ALU    = 2;
  localparam int unsigned FROM_NEXTIP = 3;
  localparam int unsigned FROM_IMM    = 4;

  // Corresponding to each branch mode type (for correct effective address calculation)
  localparam int unsigned JAL_OR_BCC = 1;
  localparam int unsigned JALR       = 2;

  // Corresponding to each data fowarding path
  localparam int unsigned FROM_EX        = 1;
  localparam int unsigned FROM_MEM       = 2;
  localparam int unsigned FROM_EXMEM_ALU = 3;
  localparam int unsigned FROM_MEMWB_ALU = 4;

  // Record type declarations for the pipeline setup

  // Instruction register -> Driver
  typedef struct {
    logic [31:0] IPAddr;
    logic [31:0] LinkAddr;
    logic [31:0] Insn;
  } insn_record_t;

  // Driver -> ALU
  typedef struct {
    logic        MemWrite;
    logic        RegWrite;
    int unsigned RFSrc;
    int unsigned ALUSrc;
    int unsigned ALUOp;
    int unsigned BGUOp;
    int unsigned LSWidth;
    logic [4:0]  RD;
    logic [4:0]  RS1;
    logic [4:0]  RS2;
    logic [31:0] DS1;
    logic [31:0] DS2;
    logic [31:0] Imm;
    logic        Break;
    int unsigned BranchMode;
    logic        IsBranch;
    logic        IPStride;    // 0 = 2bytes, 1 = 4bytes
    logic        SignExtend;  // 0 = zero-extend, 1 = sign-extend
    logic        IPToALU;
    logic [31:0] Data;
  } driver_record_t;

  // ALU -> Memory
  typedef struct {
    logic [31:0] F;
    logic        Co;
  } alu_record_t;

  // Memory -> Register file
  typedef struct {
    logic [31:0] Data;
  } mem_record_t;

  // Register File -> x (delay circuit)
  typedef struct {
    logic [31:0] F;        // MEMWB ALU result delayed
    logic [31:0] Data;     // MEMWB MemData delayed
    int unsigned Forward;  // ForwardedMemData delayed
    int unsigned LSWidth;
  } wb_record_t;

endpackage : RISCV_types