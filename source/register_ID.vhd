-- Horizon: register_ID.vhd
-- (c) 2026 Connor J. Link. All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.types.all;

entity register_ID is
    port(
        i_Clock    : in  std_logic;
        i_Reset    : in  std_logic;
        i_Stall    : in  std_logic;
        i_Flush    : in  std_logic;
        i_Signals  : in  ID_record_t;
        o_Signals  : out ID_record_t
    );
end register_ID;

architecture implementation of register_ID is
begin

    process(
        all
    )
    begin
        -- insert a NOP
        if i_Reset = '1' then
            o_Signals <= DRIVER_NOP;

        elsif rising_edge(i_Clock) then

            -- insert a NOP
            if i_Flush = '1' then
                o_Signals <= DRIVER_NOP;

            elsif i_Stall = '0' then
                o_Signals <= i_Signals;

            end if;

        end if;

    end process;

end implementation;
