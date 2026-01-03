-------------------------------------------------------------------------
-- Connor Link
-- Iowa State University
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- alu_mux.vhd
-- DESCRIPTION: This file contains an implementation of a ALU output multiplexer
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.RISCV_types.all;

entity alu_mux is
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
end alu_mux;

architecture mixed of alu_mux is

begin

    o_F <= i_addF  when (i_ALUOp = work.RISCV_types.ADD)  else
           i_subF  when (i_ALUOp = work.RISCV_types.SUB)  else
           i_andF  when (i_ALUOp = work.RISCV_types.BAND) else
           i_orF   when (i_ALUOp = work.RISCV_types.BOR)  else
           i_xorF  when (i_ALUOp = work.RISCV_types.BXOR) else
           i_sllF  when (i_ALUOp = work.RISCV_types.BSLL) else
           i_srlF  when (i_ALUOp = work.RISCV_types.BSRL) else
           i_sraF  when (i_ALUOp = work.RISCV_types.BSRA) else
           i_sltF  when (i_ALUOp = work.RISCV_types.SLT)  else
           i_sltuF when (i_ALUOp = work.RISCV_types.SLTU) else
           32x"0";

    o_Co <= i_addCo when (i_ALUOp = work.RISCV_types.ADD) else
            i_subCo when (i_ALUOp = work.RISCV_types.SUB) else
            '0';

end mixed;
