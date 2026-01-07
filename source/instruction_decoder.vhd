-- Horizon: instruction_decoder.vhd
-- (c) 2026 Connor J. Link. All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.types.all;

entity instruction_decoder is
    port(
        i_Instruction : in  std_logic_vector(31 downto 0);
        o_Opcode      : out std_logic_vector(6 downto 0);
        o_RD          : out std_logic_vector(4 downto 0);
        o_RS1         : out std_logic_vector(4 downto 0);
        o_RS2         : out std_logic_vector(4 downto 0);
        o_Funct3      : out std_logic_vector(2 downto 0);
        o_Funct7      : out std_logic_vector(6 downto 0);
        o_iImm        : out std_logic_vector(11 downto 0);
        o_sImm        : out std_logic_vector(11 downto 0);
        o_bImm        : out std_logic_vector(12 downto 0);
        o_uImm        : out std_logic_vector(31 downto 12);
        o_jImm        : out std_logic_vector(20 downto 0);
        o_hImm        : out std_logic_vector(4 downto 0)
    );
end instruction_decoder;

architecture implementation of instruction_decoder is
begin

    o_Opcode <= i_Instruction(6 downto 0);

    o_RD  <= i_Instruction(11 downto 7);
    o_RS1 <= i_Instruction(19 downto 15);
    o_RS2 <= i_Instruction(24 downto 20);

    -- shamt field is in the same position as RS2
    o_hImm <= i_Instruction(24 downto 20);

    o_Funct3 <= i_Instruction(14 downto 12);

    o_Funct7 <= i_Instruction(31 downto 25);

    o_iImm <= i_Instruction(31 downto 20);

    o_sImm(11 downto 5) <= i_Instruction(31 downto 25);
    o_sImm(4 downto 0)  <= i_Instruction(11 downto 7);

    o_bImm(12)          <= i_Instruction(31);
    o_bImm(11)          <= i_insn(7);
    o_bImm(10 downto 5) <= i_Instruction(30 downto 25);
    o_bImm(4 downto 1)  <= i_Instruction(11 downto 8);
    o_bImm(0)           <= '0';

    o_uImm <= i_insn(31 downto 12);

    o_jImm(20)           <= i_Instruction(31);
    o_jImm(19 downto 12) <= i_Instruction(19 downto 12);
    o_jImm(11)           <= i_Instruction(20);
    o_jImm(10 downto 1)  <= i_Instruction(30 downto 21);
    o_jImm(0)            <= '0';
    
end dataflow;
