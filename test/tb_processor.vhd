-- Horizon: tb_processor.vhd
-- (c) 2026 Connor J. Link. All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
library std;
use std.env.all;
use std.textio.all;
library work;
use work.types.all;

entity tb_processor is
    generic(
        CLOCK_HALF_PERIOD : time    := 10 ns;
        DATA_WIDTH        : integer := 32;
        IS_DEBUG          : boolean := false
    );
end tb_processor;

architecture implementation of tb_processor is

constant CLOCK_PERIOD : time := CLOCK_HALF_PERIOD * 2;

-- Testbench signals
signal s_Clock, s_Reset : std_logic := '0';

-- Stimulus signals
signal s_iInstructionLoad : std_logic := '0';
signal s_iInstructionAddress, s_iInstructionExternal : std_logic_vector(31 downto 0) := (others => '0');
signal s_iDataLoad : std_logic := '0';
signal s_iDataAddress, s_iDataExternal : std_logic_vector(31 downto 0) := (others => '0');
signal s_oALUOutput : std_logic_vector(31 downto 0);
signal s_oHalt : std_logic;

procedure LoadInstructionMemory(
    signal   i_Clock               : in  std_logic;
    signal   o_InstructionLoad     : out std_logic;
    signal   o_InstructionAddress  : out std_logic_vector(31 downto 0);
    signal   o_InstructionExternal : out std_logic_vector(31 downto 0);
    constant FileName              : in  string;
    constant BaseAddress           : in  std_logic_vector(31 downto 0)
) is
    file f_File : text open read_mode is FileName;
    variable v_Line    : line;
    variable v_Word    : std_logic_vector(31 downto 0);
    variable v_Address : unsigned(31 downto 0);
begin

    v_Address := unsigned(BaseAddress);

    o_InstructionLoad <= '1';

    while not endfile(f_File) loop
        readline(f_File, v_Line);

        -- Skip empty lines
        if v_Line'length = 0 then
            next;
        end if;

        hread(v_Line, v_Word);

        o_InstructionAddress  <= std_logic_vector(v_Address);
        o_InstructionExternal <= v_Word;

        -- Instruction memory writes on clock rising edge
        wait until rising_edge(i_Clock);
        if IS_DEBUG then
            report "Loaded instruction memory word " & to_hstring(v_Word) & " at address " & to_hstring(std_logic_vector(v_Address)) severity note;
        end if;
        v_Address := v_Address + 4;

    end loop;

    o_InstructionLoad     <= '0';
    o_InstructionAddress  <= (others => '0');
    o_InstructionExternal <= (others => '0');

end procedure;

procedure LoadDataMemory(
    signal   i_Clock       : in  std_logic;
    signal   o_DataAddress : out std_logic_vector(31 downto 0);
    signal   o_DataExternal: out std_logic_vector(31 downto 0);
    constant FileName      : in  string;
    constant BaseAddress   : in  std_logic_vector(31 downto 0)
) is
    file f_File : text open read_mode is FileName;
    variable v_Line    : line;
    variable v_Word    : std_logic_vector(31 downto 0);
    variable v_Address : unsigned(31 downto 0);
begin

    v_Address := unsigned(BaseAddress);

    while not endfile(f_File) loop
        readline(f_File, v_Line);

        -- Skip empty lines
        if v_Line'length = 0 then
            next;
        end if;

        hread(v_Line, v_Word);

        o_DataAddress  <= std_logic_vector(v_Address);
        o_DataExternal <= v_Word;

        -- Data memory writes on clock rising edge
        wait until rising_edge(i_Clock);
        if IS_DEBUG then
            report "Loaded data memory word " & to_hstring(v_Word) & " at address " & to_hstring(std_logic_vector(v_Address)) severity note;
        end if;
        v_Address := v_Address + 4;

    end loop;

    o_DataAddress   <= (others => '0');
    o_DataExternal  <= (others => '0');

end procedure;


begin

    -- Design-under-test instantiation
    DUT: entity work.processor
        port map(
            i_Clock               => s_Clock,
            i_Reset               => s_Reset,
            i_InstructionLoad     => s_iInstructionLoad,
            i_InstructionAddress  => s_iInstructionAddress,
            i_InstructionExternal => s_iInstructionExternal,
            i_DataLoad            => s_iDataLoad,
            i_DataAddress         => s_iDataAddress,
            i_DataExternal        => s_iDataExternal,
            o_ALUOutput           => s_oALUOutput,
            o_Halt                => s_oHalt
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


    p_Stimulus: process
        constant c_HexFile               : string := "binary/fibonacci";
        constant c_DataMemoryFile        : string := c_HexFile & "_d.hex";
        constant c_InstructionMemoryFile : string := c_HexFile & "_i.hex";
        variable v_Cycles  : integer := 0;
    begin
        -- Await reset and stabilization; trigger off-edge
        wait for CLOCK_HALF_PERIOD;
        wait for CLOCK_HALF_PERIOD / 2;

        -- Load processor instruction and data memories with target program
        LoadInstructionMemory(s_Clock, s_iInstructionLoad, s_iInstructionAddress, s_iInstructionExternal, c_InstructionMemoryFile, x"00400000");
        LoadDataMemory(s_Clock, s_iInstructionAddress, s_iInstructionExternal, c_DataMemoryFile, x"10010000");

        while s_oHalt = '0' loop
            wait until rising_edge(s_Clock);
            v_Cycles := v_Cycles + 1;

            if v_Cycles mod 1000 = 0 then
                report "Simulation running... (cycle count: " & integer'image(v_Cycles) & ")" severity note;
            end if;

        end loop;

        finish;

    end process;

end implementation;
