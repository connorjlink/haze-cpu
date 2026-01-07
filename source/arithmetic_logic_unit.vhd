-- Horizon: arithmetic_logic_unit.vhd
-- (c) 2026 Connor J. Link. All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.types.all;

entity arithmetic_logic_unit is
    generic(
        constant N : natural := 32
    );
    port(
        i_A        : in  std_logic_vector(31 downto 0);
        i_B        : in  std_logic_vector(31 downto 0);
        i_Operator : in  natural;
        o_F        : out std_logic_vector(31 downto 0);
        o_Carry    : out std_logic
    );
end arithmetic_logic_unit;

architecture implementation of arithmetic_logic_unit is

-- Signals to hold the results of each logical unit
signal s_XOROut : std_logic_vector(N-1 downto 0) := (others => '0');
signal s_OROut  : std_logic_vector(N-1 downto 0) := (others => '0');
signal s_ANDOut : std_logic_vector(N-1 downto 0) := (others => '0');

signal s_IsLessSigned   : std_logic := '0';
signal s_IsLessUnsigned : std_logic := '0';

signal s_IsArithmetic     : std_logic := '0';
signal s_IsRight          : std_logic := '0';
signal s_BarrelShifterOut : std_logic_vector(N-1 downto 0) := (others => '0');

signal s_AdderSubtractorOut : std_logic_vector(N-1 downto 0) := (others => '0');
signal s_IsSubtraction      : std_logic := '0';
signal s_CarryOut           : std_logic := '0';

begin

    ------------------------------------------------------
    -- Logical XOR, OR, AND
    ------------------------------------------------------

    g_NBit_XOR: for i in 0 to N-1
    generate
        XORI: entity work.xor_2
            port map(
                i_A => i_A(i),
                i_B => i_B(i),
                o_F => s_XOROut(i)
            );
    end generate g_NBit_XOR;

    g_NBit_OR: for i in 0 to N-1
    generate
        ORI: entity work.or_2
            port map(
                i_A => i_A(i),
                i_B => i_B(i),
                o_F => s_OROut(i)
            );
    end generate g_NBit_OR;

    g_NBit_AND: for i in 0 to N-1
    generate
        ANDI: entity work.and_2
            port map(
                i_A => i_A(i),
                i_B => i_B(i),
                o_F => s_ANDOut(i)
            );
    end generate g_NBit_AND;


    ------------------------------------------------------
    -- Adder/Subtractor
    ------------------------------------------------------

    s_IsSubtraction <= '0' when i_Operator = ADD_OPERATOR else
                       '1' when i_Operator = SUB_OPERATOR else
                       '0';

    g_NBit_ALUAdder: entity work.addersubtractor_N
        port map(
            i_A             => i_A,
            i_B             => i_B,
            i_IsSubtraction => s_IsSubtraction,
            o_S             => s_AdderSubtractorOut,
            o_Carry         => s_CarryOut
        );


    ------------------------------------------------------
    -- Barrel Shifter
    ------------------------------------------------------

    s_IsArithmetic <= '0' when i_Operator = SLL_OPERATOR or i_Operator = SRL_OPERATOR else
                      '1';

    s_IsRight <= '1' when i_Operator = SRL_OPERATOR or i_Operator = SRA_OPERATOR else
                '0';

    g_BarrelShifter: barrel_shifter
        port map(
            i_A            => i_A,
            i_B            => i_B(4 downto 0), -- log2(32) = 5
            i_IsArithmetic => s_IsArithmetic,
            i_IsRight      => s_IsRight,
            o_S            => s_BarrelShifterOut
        );


    ------------------------------------------------------
    -- Comparator
    ------------------------------------------------------

    s_IsLessUnsigned <= 32x"1" when (unsigned(i_A) < unsigned(i_B)) else
                        32x"0";
        
    s_IsLessSigned <= 32x"1" when (signed(i_A) < signed(i_B)) else
                      32x"0";

    
    ------------------------------------------------------
    -- Output Multiplexing
    ------------------------------------------------------
        
    with i_Operator select 
        o_F <= 
            s_AdderSubtractorOut when ADD_OPERATOR,
            s_AdderSubtractorOut when SUB_OPERATOR,
            s_ANDOut             when AND_OPERATOR,
            s_OROut              when OR_OPERATOR,
            s_XOROut             when XOR_OPERATOR,
            s_BarrelShifterOut   when SLL_OPERATOR,
            s_BarrelShifterOut   when SRL_OPERATOR,
            s_BarrelShifterOut   when SRA_OPERATOR,
            s_IsLessSigned       when SLT_OPERATOR,
            s_IsLessUnsigned     when SLTU_OPERATOR,
            (others => '0')      when others;

    with i_Operator select 
        o_Carry <=
            s_CarryOut when ADD_OPERATOR,
            s_CarryOut when SUB_OPERATOR,
            '0'        when others;

end implementation;
