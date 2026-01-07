-- Horizon: control_unit.vhd
-- (c) 2026 Connor J. Link. All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.types.all;
use work.extender_NtoM.all;
use work.instruction_decoder.vhd;

entity control_unit is
    port(
        i_Clock               : in  std_logic;
        i_Reset               : in  std_logic;
        i_Instruction         : in  std_logic_vector(31 downto 0);
        o_MemoryWriteEnable   : out std_logic;
        o_RegisterWriteEnable : out std_logic;
        o_RegisterSource      : out natural; -- 0 = memory, 1 = ALU, 2 = IP+4
        o_ALUSource           : out natural; -- 0 = register, 1 = immediate, 2 = big immediate (lui)
        o_ALUOperator         : out natural;
        o_BGUOperator         : out natural;
        o_MemoryWidth         : out natural;
        o_RD                  : out std_logic_vector(4 downto 0);
        o_RS1                 : out std_logic_vector(4 downto 0);
        o_RS2                 : out std_logic_vector(4 downto 0);
        o_Immediate           : out std_logic_vector(31 downto 0);
        o_BranchMode          : out natural;
        o_Break               : out std_logic;
        o_IsBranch            : out std_logic;
        o_IPToALU             : out std_logic;
        o_IPStride            : out std_logic;
        o_SignExtend          : out std_logic
    );
end control_unit;

architecture implementation of control_unit is

-- Signals to hold the results from the decoder
signal s_decOpcode : std_logic_vector(6 downto 0);
signal s_decFunc3  : std_logic_vector(2 downto 0);
signal s_decFunc7  : std_logic_vector(6 downto 0);
signal s_deciImm   : std_logic_vector(11 downto 0);
signal s_decsImm   : std_logic_vector(11 downto 0);
signal s_decbImm   : std_logic_vector(12 downto 0);
signal s_decuImm   : std_logic_vector(31 downto 12);
signal s_decjImm   : std_logic_vector(20 downto 0);
signal s_dechImm   : std_logic_vector(4 downto 0);

-- Signals to hold the results from the immediate extenders
signal s_extiImm : std_logic_vector(31 downto 0);
signal s_extsImm : std_logic_vector(31 downto 0);
signal s_extbImm : std_logic_vector(31 downto 0);
signal s_extuImm : std_logic_vector(31 downto 0);
signal s_extjImm : std_logic_vector(31 downto 0);
signal s_exthImm : std_logic_vector(31 downto 0);

signal s_SignExtend : std_logic := '0';

begin

    -- 4-byte instructions are indicated by a 11 in the two least-significant bits of the opcode
    o_IPStride <= '1' when s_decOpcode(1 downto 0) = 2b"11" else
                  '0';

    g_ControlUnitExtenderI: entity work.extender_NtoM
        generic map(
            IN_WIDTH => 12,
            OUT_WIDTH => 32
        )
        port map(
            i_D          => s_deciImm,
            i_nZero_Sign => s_SignExtend,
            o_Q          => s_extiImm
        );

    g_ControlUnitExtenderS: entity work.extender_NtoM -- S-Format
        generic map(
            IN_WIDTH => 12,
            OUT_WIDTH => 32
        )
        port map(
            i_D          => s_decsImm,
            i_nZero_Sign => s_SignExtend,
            o_Q          => s_extsImm
        );

    g_ControlUnitExtenderB: entity work.extender_NtoM -- B-Format
        generic map(
            IN_WIDTH => 13,
            OUT_WIDTH => 32
        )
        port map(
            i_D          => s_decbImm,
            i_nZero_Sign => s_SignExtend,
            o_Q          => s_extbImm
        );

    -- U-Format
    s_extuImm(31 downto 12) <= s_decuImm;
    s_extuImm(11 downto 0) <= 12x"0";

    g_ControlUnitExtenderJ: entity work.extender_NtoM -- J-Format
        generic map(
            IN_WIDTH => 21,
            OUT_WIDTH => 32
        )
        port map(
            i_D          => s_decjImm,
            i_nZero_Sign => s_SignExtend,
            o_Q          => s_extjImm
        );

    -- "H"-format for shift immediate
    s_exthImm(31 downto 5) <= 27x"0";
    s_exthImm(4 downto 0) <= s_dechImm;


    g_InstructionDecoder: decoder
        port map(
            i_Clock       => i_Clock,
            i_Reset       => i_Reset,
            i_Instruction => i_Instruction,
            o_Opcode      => s_decOpcode,
            o_RD          => o_RD,
            o_RS1         => o_RS1,
            o_RS2         => o_RS2,
            o_Func3       => s_decFunc3,
            o_Func7       => s_decFunc7,
            o_iImm        => s_deciImm,
            o_sImm        => s_decsImm,
            o_bImm        => s_decbImm,
            o_uImm        => s_decuImm,
            o_jImm        => s_decjImm,
            o_hImm        => s_dechImm
        );

    process(
        all
    )
        variable v_IsBranch            : std_logic;
        variable v_Break               : std_logic;
        variable v_IsSignExtend        : std_logic;
        variable v_MemoryWriteEnable   : std_logic;
        variable v_RegisterWriteEnable : std_logic;
        variable v_ALUSource           : natural;
        variable v_RegisterSource      : natural; -- 0 = memory, 1 = ALU, 2 = next IP
        variable v_ALUOperator         : natural;
        variable v_BGUOperator         : natural;
        variable v_MemoryWidth         : natural := 0;
        variable v_Immediate           : std_logic_vector(31 downto 0);
        variable v_BranchMode          : natural;
        variable v_IPToALU             : std_logic;

    begin 
        if i_Reset = '0' then
            v_IsBranch            := '0';
            v_Break               := '0';
            v_IsSignExtend        := '1'; -- 0: zero-extend, 1: sign-extend
            v_MemoryWriteEnable   := '0';
            v_RegisterWriteEnable := '0';
            v_ALUSource           := work.types.ALUSRC_REG; -- default is to put DS1 and DS2 into the ALU
            v_RegisterSource      := 0;
            v_ALUOperator         := 0;
            v_BGUOperator         := 0;
            v_MemoryWidth         := 0;
            v_Immediate           := 32x"0";
            v_BranchMode          := 0;
            v_IPToALU             := '0';

            case s_decOpcode is 
                when 7b"1101111" => -- J-Format
                    -- jal    - rd <= linkAddr
                    v_Immediate := s_extjImm;
                    v_BGUOperator := work.types.J;
                    v_RegisterWriteEnable := '1';
                    v_RegisterSource := work.types.FROM_NEXTIP;
                    v_BranchMode := work.types.JAL_OR_BCC;
                    -- NOTE: not setting the branch flag to indicate that this is a jump instead of a branch
                    --v_IsBranch := '1';
                    report "jal" severity note;

                when 7b"1100111" => -- I-Format
                    -- jalr - func3=000 - rd <= linkAddr
                    v_Immediate := s_extiImm;
                    v_BGUOperator := work.types.J;
                    v_RegisterWriteEnable := '1';
                    v_RegisterSource := work.types.FROM_NEXTIP;
                    v_BranchMode := work.types.JALR;
                    -- NOTE: not setting the branch flag to indicate that this is a jump instead of a branch
                    --v_IsBranch := '1';
                    report "jalr" severity note;

                when 7b"0010011" => -- I-format
                    v_RegisterWriteEnable := '1';
                    v_ALUSource := work.types.ALUSRC_IMM;
                    v_RegisterSource := work.types.FROM_ALU;
                    v_Immediate := s_extiImm;

                    case s_decFunc3 is
                        when 3b"000" =>
                            -- NOTE: there is no `subi` because addi with negative is mostly equivalent
                            v_ALUOperator := work.types.ADD;
                            report "addi" severity note;

                        when 3b"001" =>
                            -- slli  - 001
                            v_ALUOperator := work.types.BSLL;
                            v_Immediate := s_exthImm; -- override for shamt
                            report "slli" severity note;

                        when 3b"010" => 
                            -- slti  - 010
                            v_ALUOperator := work.types.SLT;
                            report "slti" severity note;

                        when 3b"011" =>
                            -- sltiu - 011
                            v_ALUOperator := work.types.SLTU;
                            report "sltiu" severity note;

                        when 3b"100" =>
                            -- xori  - 100
                            v_ALUOperator := work.types.BXOR;
                            report "xori" severity note;

                        when 3b"101" =>
                            -- shtype field is equivalent to func7
                            if s_decFunc7 = 7b"0100000" then
                                -- srai - 101 + 0100000
                                v_ALUOperator := work.types.BSRA;
                                v_Immediate := s_exthImm; -- override for shamt
                                report "srai" severity note;

                            else
                                -- srli - 101 + 0000000
                                v_ALUOperator := work.types.BSRL;
                                v_Immediate := s_exthImm; -- override for shamt
                                report "srli" severity note;
                            
                            end if;

                        when 3b"110" =>
                            -- ori  - 110
                            v_ALUOperator := work.types.BOR;
                            report "ori" severity note;

                        when 3b"111" =>
                            -- andi - 111
                            v_ALUOperator := work.types.BAND;
                            report "andi" severity note;

                        when others =>
                            v_Break := '1';
                            report "Illegal I-Format Instruction" severity error;
                    end case;

                when 7b"0000011" => -- I-Format? More
                    v_RegisterWriteEnable := '1';
                    v_RegisterSource := work.types.FROM_RAM;
                    v_ALUSource := work.types.ALUSRC_IMM; --?
                    v_Immediate := s_extiImm;

                    case s_decFunc3 is
                        when 3b"000" =>
                            -- lb   - 000
                            v_IsSignExtend := '1';
                            v_MemoryWidth := work.types.BYTE;
                            report "lb" severity note;

                        when 3b"001" =>
                            -- lh   - 001
                            v_IsSignExtend := '1';
                            v_MemoryWidth := work.types.HALF;
                            report "lh" severity note;

                        when 3b"010" =>
                            -- lw   - 010
                            v_IsSignExtend := '1';
                            v_MemoryWidth := work.types.WORD;
                            report "lw" severity note;

                        -- RV64I
                        --when 3b"011" =>
                        --    -- ld   - 011
                        --    v_MemoryWidth := work.types.DOUBLE;
                        --    report "ld" severity note;

                        when 3b"100" =>
                            -- lbu  - 100
                            v_IsSignExtend := '0';
                            v_MemoryWidth := work.types.BYTE;
                            report "lbu" severity note;

                        when 3b"101" =>
                            -- lhu  - 101
                            v_IsSignExtend := '0';
                            v_MemoryWidth := work.types.HALF;
                            report "lhu" severity note;

                        -- NOTE: unoffical instruction for RV32I
                        when 3b"110" =>
                            -- lwu  - 110
                            v_IsSignExtend := '0';
                            v_MemoryWidth := work.types.WORD;
                            report "lwu" severity note;

                        -- NOTE: unoffical instruction for RV64I
                        --when 3b"111" =>
                        --    -- ldu  - 111
                        --    v_IsSignExtend := '0';
                        --    v_MemoryWidth := work.types.DOUBLE;
                        --    report "ldu" severity note;

                        when others =>
                            v_Break := '1';
                            report "Illegal I-Format? More Instruction" severity error;
                    end case;

                when 7b"0100011" => -- S-Format
                    v_MemoryWriteEnable := '1';
                    v_ALUSource := work.types.ALUSRC_IMM;
                    v_Immediate := s_extsImm;

                    case s_decFunc3 is
                        when 3b"000" =>
                            -- sb   - 000
                            v_MemoryWidth := work.types.BYTE;
                            report "sb" severity note;

                        when 3b"001" =>
                            -- sh   - 001
                            v_MemoryWidth := work.types.HALF;
                            report "sh" severity note;

                        when 3b"010" =>
                            -- sw   - 010
                            v_MemoryWidth := work.types.WORD;
                            report "sw" severity note;

                        -- RV64I
                        --when 3b"011" =>
                        --    -- sd   - 011
                        --    v_MemoryWidth := work.types.DOUBLE;
                        --    report "sd" severity note;

                        when others =>
                            v_Break := '1';
                            report "Illegal S-Format Instruction" severity error;
                    end case;

                when 7b"0110011" => -- R-format
                    v_RegisterWriteEnable := '1';
                    v_RegisterSource := work.types.FROM_ALU;
                    v_ALUSource := work.types.ALUSRC_REG;

                    case s_decFunc3 is
                        when 3b"000" =>
                            if s_decFunc7 = 7b"0100000" then
                                -- sub  - 000 + 0100000
                                v_ALUOperator := work.types.SUB;
                                report "sub" severity note;

                            else
                                -- add  - 000 + 0000000
                                v_ALUOperator := work.types.ADD;
                                report "add" severity note;

                            end if;

                        when 3b"001" =>
                            -- sll  - 001 + 0000000
                            v_ALUOperator := work.types.BSLL;
                            report "sll" severity note;

                        when 3b"010" =>
                            -- slt  - 010 + 0000000
                            v_ALUOperator := work.types.SLT;
                            report "slt" severity note;

                        when 3b"011" =>
                            -- sltu - 011 + 0000000
                            v_ALUOperator := work.types.SLTU;
                            report "sltu" severity note;

                        when 3b"100" =>
                            -- xor  - 100 + 0000000
                            v_ALUOperator := work.types.BXOR;
                            report "xor" severity note;

                        when 3b"101" =>
                            -- shtype field is equivalent to func7
                            if s_decFunc7 = 7b"0100000" then
                                -- sra - 101 + 0100000
                                v_ALUOperator := work.types.BSRA;
                                report "sra" severity note;

                            else
                                -- srl - 101 + 0000000
                                v_ALUOperator := work.types.BSRL;
                                report "srl" severity note;

                            end if;

                        when 3b"110" =>
                            -- or   - 110 + 0000000
                            v_ALUOperator := work.types.BOR;
                            report "or" severity note;

                        when 3b"111" =>
                            -- and  - 111 + 0000000
                            v_ALUOperator := work.types.BAND;
                            report "and" severity note;

                        when others =>
                            v_Break := '1';
                            report "Illegal R-Format Instruction" severity error;
                    end case;

                when 7b"1100011" => -- B-Format
                    v_Immediate := s_extbImm;
                    -- v_ALUSource := work.types.ALUSRC_IMM;
                    -- v_IPToALU := '1';
                    v_BranchMode := work.types.JAL_OR_BCC;
                    v_IsBranch := '1';

                    case s_decFunc3 is 
                        when 3b"000" =>
                            -- beq  - 000
                            v_BGUOperator := work.types.BEQ;
                            report "beq" severity note;

                        when 3b"001" =>
                            -- bne  - 001
                            v_BGUOperator := work.types.BNE;
                            report "bne" severity note;

                        when 3b"100" =>
                            -- blt  - 100
                            v_BGUOperator := work.types.BLT;
                            report "blt" severity note;

                        when 3b"101" =>
                            -- bge  - 101
                            v_BGUOperator := work.types.BGE;
                            report "bge" severity note;

                        when 3b"110" =>
                            -- bltu - 110
                            v_BGUOperator := work.types.BLTU;
                            report "bltu" severity note;

                        when 3b"111" =>
                            -- bgeu - 111
                            v_BGUOperator := work.types.BGEU;
                            report "bgeu" severity note;

                        when others =>
                            v_Break := '1';
                            report "Illegal B-Format Instruction" severity error;
                    end case;

                when 7b"0110111" => -- U-Format
                    -- lui   - rd = imm << 12
                    v_Immediate := s_extuImm;
                    v_RegisterSource := work.types.FROM_IMM;
                    v_ALUSource := work.types.ALUSRC_BIGIMM;
                    v_RegisterWriteEnable := '1';
                    report "lui" severity note;

                when 7b"0010111" => -- U-Format
                    -- auipc - rd = pc + (imm << 12)
                    v_Immediate := s_extuImm;
                    v_RegisterSource := work.types.FROM_ALU;
                    v_ALUSource := work.types.ALUSRC_IMM;
                    v_IPToALU := '1';
                    v_RegisterWriteEnable := '1';
                    report "auipc" severity note;

                when 7b"0001111" => -- fence
                    -- since this core is running scalar, in-order, and single-tasking, this can safely be left as a NOP
                    report "fence" severity note;

                when 7b"1110011" => -- ecall/ebreak
                    if i_Instruction = 32b"00000000000100000000000001110011" then
                        -- ebreak
                        v_Break := '1';
                        report "ebreak" severity note; 
                    else
                        -- ecall
                        report "ecall" severity note;
                    end if;

                when others =>
                    v_Break := '1';
                    report "Illegal Instruction" severity error;
            end case;
        else
            v_IsBranch            := '0';
            v_Break               := '0';
            v_IsSignExtend        := '1'; -- default case is sign extension
            v_MemoryWriteEnable   := '0';
            v_RegisterWriteEnable := '0';
            v_RegisterSource      := 0;
            v_ALUSource           := work.types.ALUSRC_REG;
            v_ALUOperator         := 0;
            v_BGUOperator         := 0;
            v_MemoryWidth         := 0;
            v_Immediate           := 32x"0";
            v_BranchMode          := 0;
            v_IPToALU             := '0';
        end if;

        o_IsBranch            <= v_IsBranch;
        o_Break               <= v_Break;
        o_SignExtend          <= v_IsSignExtend;
        s_SignExtend          <= v_IsSignExtend;
        o_MemoryWriteEnable   <= v_MemoryWriteEnable; 
        o_RegisterWriteEnable <= v_RegisterWriteEnable; 
        o_RegisterSource      <= v_RegisterSource;    
        o_ALUSource           <= v_ALUSource;   
        o_ALUOperator         <= v_ALUOperator;    
        o_BGUOperator         <= v_BGUOperator; 
        o_MemoryWidth         <= v_MemoryWidth;   
        o_Immediate           <= v_Immediate;  
        o_BranchMode          <= v_BranchMode;   
        o_ipToALU             <= v_IPToALU; 
    end process;

end implementation;
