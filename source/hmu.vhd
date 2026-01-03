-------------------------------------------------------------------------
-- Connor Link
-- Iowa State University
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- hmu.vhd
-- DESCRIPTION: This file contains an implementation of a basic RISC-V hazard management unit.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.RISCV_types.all;

entity hmu is
    port(
        i_IFID_RS1       : in  std_logic_vector(4 downto 0);
        i_IFID_RS2       : in  std_logic_vector(4 downto 0);
        i_IFID_IsLoad    : in  std_logic;
        i_IFID_MemWrite  : in  std_logic;

        i_IDEX_RD        : in  std_logic_vector(4 downto 0);
        i_IDEX_RS1       : in  std_logic_vector(4 downto 0);
        i_IDEX_RS2       : in  std_logic_vector(4 downto 0);
        i_IDEX_IsLoad    : in  std_logic;

        i_EXMEM_RS1      : in  std_logic_vector(4 downto 0);
        i_EXMEM_RS2      : in  std_logic_vector(4 downto 0);
        i_EXMEM_RD       : in  std_logic_vector(4 downto 0);
        i_EXMEM_IsLoad   : in  std_logic;
        i_EXMEM_RegWrite : in  std_logic;

        i_MEMWB_RD       : in  std_logic_vector(4 downto 0);
        i_MEMWB_IsLoad   : in  std_logic;

        i_BranchMode     : in  natural;
        i_BranchTaken    : in  std_logic;
        
        i_IDEX_IsBranch  : in  std_logic;
        i_MEMWB_IsBranch : in  std_logic;


        o_Break          : out std_logic;

        o_IFID_Flush     : out std_logic;
        o_IFID_Stall     : out std_logic;

        o_IDEX_Flush     : out std_logic;
        o_IDEX_Stall     : out std_logic;

        o_EXMEM_Flush    : out std_logic;
        o_EXMEM_Stall    : out std_logic
    );
end hmu;

architecture mixed of hmu is

begin
    
    process(
        all
    )
        variable v_IP_Stall    : std_logic := '0';
        variable v_IFID_Flush  : std_logic := '0';
        variable v_IFID_Stall  : std_logic := '0';
        variable v_IDEX_Flush  : std_logic := '0';
        variable v_IDEX_Stall  : std_logic := '0';
        variable v_EXMEM_Flush : std_logic := '0';
        variable v_EXMEM_Stall : std_logic := '0';

    begin
        v_IP_Stall    := '0';
        v_IFID_Flush  := '0';
        v_IFID_Stall  := '0';
        v_IDEX_Flush  := '0';
        v_IDEX_Stall  := '0';
        v_EXMEM_Flush := '0';
        v_EXMEM_Stall := '0';


        -- Detect jal/j, which doesn't rely on any external data to execute, but will need to clear the pipeline until the remaining instructions are committed
        if i_BranchMode = work.RISCV_types.JAL_OR_BCC and i_IDEX_IsBranch = '0' then
            -- No extra dependencies, so branch is computed taken, no stall to allow IP to update
            --v_IP_Stall := '1';
            v_IFID_Flush := '1';
            v_IDEX_Flush := '1';
            report "NON-HAZARD BRANCH DETECTED: jal" severity note;


        -- Detect jalr/jr, which relies on the source register for the branch target
        elsif (i_BranchMode = work.RISCV_types.JALR) or
              (i_BranchMode = work.RISCV_types.JAL_OR_BCC and i_IDEX_IsBranch = '1') then

            -- NOTE: if jr, then the link register is x0 which will never cause a hazard
            if (i_IDEX_RD = i_IFID_RS1 and i_IDEX_RD /= 5x"0") or
               (i_IDEX_RD = i_IFID_RS2 and i_IDEX_RD /= 5x"0") then 

                v_IP_Stall := '1';
                v_IFID_Stall := '1';
                v_IDEX_Flush := '1';
                report "HAZARD DETECTED: bcc/jalr" severity note;

            else
                -- Detect Bcc conditions taken/not taken
                if i_IDEX_IsBranch = '1' then 
                    if i_BranchTaken = '1' then
                        -- No extra dependencies, so branch is computed taken, no stall to allow IP to update
                        v_IFID_Flush := '1';
                        v_IDEX_Flush := '1';
                        report "BRANCH TAKER: bcc" severity note;

                    else
                        report "BRANCH NOT TAKEN: bcc" severity note;

                    end if;

                -- When non-hazard jalr/jr
                else
                    v_IP_Stall := '1';
                    v_IFID_Stall := '1';
                    v_IFID_Flush := '1';
                    v_IDEX_Flush := '1';
                    report "NON-HAZARD BRANCH: jalr" severity note;

                end if;

            end if;

        end if;

        
        -- Fixes triplet instruction sequences like:
        --   addi t2, t2, 4
        --   ...
        --   sw t2, 0(t3)
        if i_EXMEM_RegWrite = '1' and i_IFID_IsLoad = '1' and i_IFID_MemWrite = '1' and (i_EXMEM_RD = i_IFID_RS1 or i_EXMEM_RD = i_IFID_RS2) and i_EXMEM_RD /= 5x"0" then
            v_IP_Stall := '1';
            v_IFID_Stall := '1';
            v_IDEX_Flush := '1';
            report "HAZARD DETECTED: compute-store" severity note;

        
        -- Fixes triplet instruction sequences like:
        --   lw t2, 0(t3)
        --   ...
        --   lw t3, 0(t2)
        elsif i_EXMEM_RegWrite = '1' and i_EXMEM_IsLoad = '1' and i_IDEX_IsLoad = '1' and (i_EXMEM_RD = i_IDEX_RS1 or i_EXMEM_RD = i_IDEX_RS2) and i_EXMEM_RD /= 5x"0" then
            v_IP_Stall := '1';
            v_IFID_Stall := '1';
            v_IDEX_Stall := '1';
            v_EXMEM_Flush := '1';
            report "HAZARD DETECTED: load-load" severity note;


        -- Fixes triplet instruction sequences like (which will have been already partially expanded):
        --   addi t2, t2, 1
        --   addi t3, t3, 1
        --   add  t4, t2, t3
        elsif i_EXMEM_RegWrite = '1' and i_EXMEM_RD /= 5x"0" and i_EXMEM_RD = i_IFID_RS2 and i_IFID_IsLoad = '0' then
            v_IP_Stall := '1';
            v_IFID_Stall := '1';
            v_IDEX_Flush := '1';
            report "HAZARD DETECTED: compute-use" severity note;


        -- Fixes duplet instruction sequences like:
        --   lw t2, 0(t3)
        --   addi t2, t2, 1
        elsif (i_IDEX_IsLoad = '0' and i_IFID_IsLoad = '1' and (i_IDEX_RD = i_IFID_RS1 or i_IDEX_RD = i_IFID_RS2) and i_IDEX_RD /= 5x"0") or
              (i_IDEX_IsLoad = '1' and i_IFID_IsLoad = '0' and (i_IDEX_RD = i_IFID_RS1 or i_IDEX_RD = i_IFID_RS2) and i_IDEX_RD /= 5x"0") then
            v_IP_Stall := '1';
            v_IFID_Stall := '1';
            v_IDEX_Flush := '1';
            report "HAZARD DETECTED: load-use" severity note;


        -- NOTE: functionally correct without these cases
        -- NOTE: only be RS2 because the `sw` instruction only uses RS2 for its source operand
        -- elsif (i_EXMEM_IsLoad = '1' and i_IDEX_IsLoad = '1' and (i_EXMEM_RD = i_IDEX_RS2) and i_EXMEM_RD /= 5x"0") then 
        --     v_IP_Stall := '1';
        --     v_IFID_Stall := '1';
        --     v_IDEX_Stall := '1';
        --     v_EXMEM_Flush := '1';
        --     report "HAZARD DETECTED: load-store hazard" severity note;

        -- NOTE: only be RS1 because the `lw` instruction only uses RS1 for its base address operand
        -- elsif (i_EXMEM_IsLoad = '1' and i_IDEX_IsLoad = '1' and (i_EXMEM_RD = i_IDEX_RS1) and i_EXMEM_RD /= 5x"0") then
        --     v_IP_Stall := '1';
        --     v_IFID_Stall := '1';
        --     v_IDEX_Stall := '1';
        --     v_EXMEM_Flush := '1';
        --     report "HAZARD DETECTED: load-load address hazard" severity note;

        end if;


        o_Break       <= v_IP_Stall;
        o_IFID_Flush  <= v_IFID_Flush;
        o_IFID_Stall  <= v_IFID_Stall;
        o_IDEX_Flush  <= v_IDEX_Flush;
        o_IDEX_Stall  <= v_IDEX_Stall;
        o_EXMEM_Flush <= v_EXMEM_Flush;
        o_EXMEM_Stall <= v_EXMEM_Stall;

    end process;

end mixed;
