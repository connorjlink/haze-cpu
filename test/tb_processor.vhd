-- Horizon: tb_processor.vhd
-- (c) 2026 Connor J. Link. All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
library std;
use std.env.all;
use std.textio.all;
library work;
use work.types.all;

entity tb_processor is
    generic(
        CLOCK_HALF_PERIOD : time    := 10 ns;
        DATA_WIDTH        : integer := 32
    );
end tb_processor;

architecture implementation of tb_processor is

constant CLOCK_PERIOD : time := CLOCK_HALF_PERIOD * 2;

-- Testbench signals
signal s_Clock, s_Reset : std_logic := '0';

-- Stimulus signals
signal s_iInstructionLoad : std_logic := '0';
signal s_iInstructionAddress, s_iInstructionExternal, s_oALUOutput : std_logic_vector(31 downto 0) := 32x"0";


begin

    -- Design-under-test instantiation
    DUT: entity work.processor
        port map(
            i_Clock               => s_Clock,
            i_Reset               => s_Reset,
            i_InstructionLoad     => s_iInstructionLoad,
            i_InstructionAddress  => s_iInstructionAddress,
            i_InstructionExternal => s_iInstructionExternal,
            o_ALUOutput           => s_oALUOutput
        );


    p_Clock: process
    begin
        s_Clock <= '1';
        wait for CLOCK_HALF_PERIOD;
        s_Clock <= '0';
        wait for CLOCK_HALF_PERIOD;
    end process;

    p_Reset: process
    begin
        s_Reset <= '0';
        wait for CLOCK_HALF_PERIOD / 2;
        s_Reset <= '1';
        wait for CLOCK_PERIOD;
        s_Reset <= '0';
        wait;
    end process;


-- Assign inputs 
P_TEST_CASES: process
begin
    wait for CLOCK_HALF_PERIOD;
    wait for CLOCK_HALF_PERIOD/2; -- don't change inputs on clock edges
    wait for CLOCK_PERIOD;

    -- running loaded hex binary image
    
    wait;
end process;

end implementation;
