-------------------------------------------------------------------------
-- Connor Link
-- Iowa State University
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- alu.vhd
-- DESCRIPTION: This file contains an implementation of a basic RISC-V arithmetic logic unit.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.RISCV_types.all;

entity alu is
    generic(
        -- Data width in bits
        constant N : natural := 32
    );
    port(
        i_A     : in  std_logic_vector(31 downto 0);
        i_B     : in  std_logic_vector(31 downto 0);
        i_ALUOp : in  natural;
        o_F     : out std_logic_vector(31 downto 0);
        o_Co    : out std_logic
    );
end alu;

architecture structural of alu is

component addsub_N is
    generic(
        N : integer := 32
    );
    port(
        i_A        : in  std_logic_vector(N-1 downto 0);
        i_B        : in  std_logic_vector(N-1 downto 0);
        i_nAdd_Sub : in  std_logic;
        o_S        : out std_logic_vector(N-1 downto 0);
        o_Co       : out std_logic
    );
end component;

component xorg2 is
    port(
        i_A : in  std_logic;
        i_B : in  std_logic;
        o_F : out std_logic
    );
end component;

component org2 is
    port(
        i_A : in  std_logic;
        i_B : in  std_logic;
        o_F : out std_logic
    );
end component;

component andg2 is
    port(
        i_A : in  std_logic;
        i_B : in  std_logic;
        o_F : out std_logic
    );
end component;

component set_less is
    port(i_A     : in  std_logic_vector(31 downto 0);
         i_B     : in  std_logic_vector(31 downto 0);
         o_Less  : out std_logic_vector(31 downto 0);
         o_LessU : out std_logic_vector(31 downto 0));
end component;

component alu_mux is
    port(i_addF  : in  std_logic_vector(31 downto 0);  
         i_subF  : in  std_logic_vector(31 downto 0);  
         i_andF  : in  std_logic_vector(31 downto 0);  
         i_orF   : in  std_logic_vector(31 downto 0);  
         i_xorF  : in  std_logic_vector(31 downto 0);  
         i_sllF  : in  std_logic_vector(31 downto 0);  
         i_srlF  : in  std_logic_vector(31 downto 0);  
         i_sraF  : in  std_logic_vector(31 downto 0);  
         i_sltF  : in  std_logic_vector(31 downto 0);  
         i_sltuF : in  std_logic_vector(31 downto 0);
         i_addCo : in  std_logic;
         i_subCo : in  std_logic;
         i_ALUOp : in  natural;  
         o_F     : out std_logic_vector(31 downto 0);
         o_Co    : out std_logic);
end component;

component barrel_shifter is
    port(i_A  : in  std_logic_vector(31 downto 0);  -- shift input
         i_B  : in  std_logic_vector(4 downto 0);   -- shift amount
         i_NLogical_Arithmetic : in  std_logic;     -- 0 = logical, 1 = arithmetic
         i_NLeft_Right : in std_logic;              -- 0 = left, 1 = right
         o_S  : out std_logic_vector(31 downto 0));
end component;

-- Signals to hold the results of each logical unit
signal s_xorF : std_logic_vector(N-1 downto 0);
signal s_orF  : std_logic_vector(N-1 downto 0);
signal s_andF : std_logic_vector(N-1 downto 0);
signal s_addF : std_logic_vector(N-1 downto 0);
signal s_subF : std_logic_vector(N-1 downto 0);
signal s_sllF : std_logic_vector(N-1 downto 0);
signal s_srlF : std_logic_vector(N-1 downto 0);
signal s_sraF : std_logic_vector(N-1 downto 0);
signal s_sltF : std_logic_vector(N-1 downto 0);
signal s_sltuF : std_logic_vector(N-1 downto 0);

signal s_addCo : std_logic;
signal s_subCo : std_logic;

begin

    -- XOR Unit
    g_NBit_XOR: for i in 0 to N-1
    generate
        XORI: xorg2
            port MAP(
                i_A => i_A(i),
                i_B => i_B(i),
                o_F => s_xorF(i)
            );
    end generate g_NBit_XOR;

    -- OR Unit
    g_NBit_OR: for i in 0 to N-1
    generate
        ORI: org2
            port MAP(
                i_A => i_A(i),
                i_B => i_B(i),
                o_F => s_orF(i)
            );
    end generate g_NBit_OR;

    -- AND Unit
    g_NBit_AND: for i in 0 to N-1
    generate
        ANDI: andg2
            port MAP(
                i_A => i_A(i),
                i_B => i_B(i),
                o_F => s_andF(i)
            );
    end generate g_NBit_AND;

    -- Adder Unit
    g_NBit_ALUAdder: addsub_N
        port MAP(
            i_A        => i_A,
            i_B        => i_B,
            i_nAdd_Sub => '0',
            o_S        => s_addF,
            o_Co       => s_addCo
        );

    -- Subtractor Unit
    g_NBitALUSubtractor: addsub_N
        port MAP(
            i_A        => i_A,
            i_B        => i_B,
            i_nAdd_Sub => '1',
            o_S        => s_subF,
            o_Co       => s_subCo
        );

    -- Unsigned = logical; signed = arithmetic
    -- for shifts, use dedicated hardware for each instruction and then mux between them at the end
    
    -- Left Shift Unit
    g_BarrelShifterLeft: barrel_shifter
        port MAP(
            i_A  => i_A,
            i_B  => i_B(4 downto 0), -- log2(32) = 5
            i_NLogical_Arithmetic => '0', -- Logical shift
            i_NLeft_Right => '0', -- Left shift
            o_S  => s_sllF
        );

    -- Right Shift Unit
    g_BarrelShifterRightLogical: barrel_shifter
        port MAP(
            i_A  => i_A,
            i_B  => i_B(4 downto 0), -- log2(32) = 5
            i_NLogical_Arithmetic => '0', -- Logical shift
            i_NLeft_Right => '1', -- Right shift
            o_S  => s_srlF
        );
    g_BarrelShifterRightArithmetic: barrel_shifter
        port MAP(
            i_A  => i_A,
            i_B  => i_B(4 downto 0), -- log2(32) = 5
            i_NLogical_Arithmetic => '1', -- Arithmetic shift
            i_NLeft_Right => '1', -- Right shift
            o_S  => s_sraF
        );

    -- Set-less-than Unit
    g_SetLessThan: set_less 
        port MAP(
            i_A => i_A,
            i_B => i_B,
            o_Less => s_sltF,
            o_LessU  => s_sltuF
        );

    -- Main output multiplexors 
    g_ALU_OutputMux: alu_mux
        port MAP(
            i_addF  => s_addF,
            i_subF  => s_subF,
            i_andF  => s_andF,
            i_orF   => s_orF,
            i_xorF  => s_xorF,
            i_sllF  => s_sllF,
            i_srlF  => s_srlF,
            i_sraF  => s_sraF,
            i_sltF  => s_sltF,
            i_sltuF => s_sltuF,
            i_addCo => s_addCo,
            i_subCo => s_subCo,
            i_ALUOp => i_ALUOp,
            o_F     => o_F,
            o_Co    => o_Co
        );

end structural;
