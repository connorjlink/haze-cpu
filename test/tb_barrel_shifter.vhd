-------------------------------------------------------------------------
-- Connor Link
-- Iowa State University
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- tb_barrel_shifter.vhd
-- DESCRIPTION: This file contains an implementation of a simple barrel shifter for the RISC-V ALU.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library std;
use std.env.all;
use std.textio.all;
library work;
use work.RISCV_types.all;

entity tb_barrel_shifter is
    generic(gCLK_HPER  : time := 10 ns;
     	    DATA_WIDTH : integer := 32);
end tb_barrel_shifter;

architecture mixed of tb_barrel_shifter is

-- Total clock period
constant cCLK_PER : time := gCLK_HPER * 2;

-- Element under test
component barrel_shifter is
    port(i_A  : in  std_logic_vector(31 downto 0);  -- shift input
         i_B  : in  std_logic_vector(4 downto 0);   -- shift amount
         i_NLogical_Arithmetic : in  std_logic;     -- 0 = logical, 1 = arithmetic
         i_NLeft_Right : in std_logic;              -- 0 = left, 1 = right
         o_S  : out std_logic_vector(31 downto 0));
end component;

-- Create helper signals
signal CLK, reset : std_logic := '0';

-- Create input and output signals for the module under test
signal s_iA : std_logic_vector(31 downto 0) := 32x"0";
signal s_iB : std_logic_vector(31 downto 0) := 32x"0";
signal s_iNLogical_Arithmetic : std_logic := '0';
signal s_iNLeft_Right : std_logic := '0';
signal s_oF : std_logic_vector(31 downto 0);

begin

-- Instantiate the module under test
DUT0: barrel_shifter
    port map(
        i_A                   => s_iA,
        i_B                   => s_iB(4 downto 0),
        i_NLogical_Arithmetic => s_iNLogical_Arithmetic,
        i_NLeft_Right         => s_iNLeft_Right,
        o_S                   => s_oF
    );

--This first process is to setup the clock for the test bench
P_CLK: process
begin
	CLK <= '1';         -- clock starts at 1
	wait for gCLK_HPER; -- after half a cycle
	CLK <= '0';         -- clock becomes a 0 (negative edge)
	wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
end process;

-- This process resets the sequential components of the design.
-- It is held to be 1 across both the negative and positive edges of the clock
-- so it works regardless of whether the design uses synchronous (pos or neg edge)
-- or asynchronous resets.
P_RST: process
begin
	reset <= '0';   
	wait for gCLK_HPER/2;
	reset <= '1';
	wait for gCLK_HPER*2;
	reset <= '0';
	wait;
end process;  


-- Assign inputs 
P_TEST_CASES: process
begin
    wait for gCLK_HPER;
	wait for gCLK_HPER/2; -- don't change inputs on clock edges
    wait for gCLK_HPER * 2;

    -- srl
    -- Test Case 6.1
    s_iA <= 32x"80000000";
    s_iB <= 32x"1";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $40000000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"2";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $20000000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"3";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $10000000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"4";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $08000000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"5";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $04000000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"6";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $02000000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"7";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $01000000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"8";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00800000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"9";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00400000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"A";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00200000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"B";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00100000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"C";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00080000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"D";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00040000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"E";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00020000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"F";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00010000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"10";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00008000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"11";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00004000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"12";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00002000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"13";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00001000

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"14";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000800

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"15";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000400

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"16";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000200

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"17";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000100

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"18";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000080

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"19";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000040

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"1A";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000020

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"1B";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000010

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"1C";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000008

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"1D";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000004

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"1E";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000002

    -- Test Case 6.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"1F";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000001

    -- Test Case 6.3
    s_iA <= 32x"00FF0000";
    s_iB <= 32x"1";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $007F8000

    -- Test Case 6.4
    s_iA <= 32x"00FF0000";
    s_iB <= 32x"1F";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $00000000

    -- Test Case 6.5
    s_iA <= 32x"00FF0000";
    s_iB <= 32x"10";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $000000FF


    -- sra
    -- Test Case 7.1
    s_iA <= 32x"80000000";
    s_iB <= 32x"1";
    s_iNLogical_Arithmetic <= '1';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $C0000000, s_oCo to be 0

    -- Test Case 7.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"2";
    s_iNLogical_Arithmetic <= '1';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $E0000000, s_oCo to be 0

    -- Test Case 7.2
    s_iA <= 32x"80000000";
    s_iB <= 32x"3";
    s_iNLogical_Arithmetic <= '1';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $F0000000, s_oCo to be 0

    -- Test Case 7.3
    s_iA <= 32x"80000000";
    s_iB <= 32x"1";
    s_iNLogical_Arithmetic <= '1';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $40000000, s_oCo to be 0

    -- Test Case 7.4
    s_iA <= 32x"80000000";
    s_iB <= 32x"1F";
    s_iNLogical_Arithmetic <= '1';
    s_iNLeft_Right <= '1';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $40000000, s_oCo to be 0

    
    -- sll
    -- Test Case 8.1
    s_iA <= 32x"80000000";
    s_iB <= 32x"1";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '0';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $C0000000, s_oCo to be 0

    -- Test Case 8.2
    s_iA <= 32x"00000001";
    s_iB <= 32x"2";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '0';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $E0000000, s_oCo to be 0

    -- Test Case 8.3
    s_iA <= 32x"00000001";
    s_iB <= 32x"1";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '0';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $C0000000, s_oCo to be 0

    -- Test Case 8.4
    s_iA <= 32x"00000001";
    s_iB <= 32x"1F";
    s_iNLogical_Arithmetic <= '0';
    s_iNLeft_Right <= '0';
    wait for gCLK_HPER * 2;
    -- Expect s_oF to be $FFFFFFFF, s_oCo to be 0

    wait;
end process;

end mixed;