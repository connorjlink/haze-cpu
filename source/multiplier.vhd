-- Horizon: multiplier.vhd
-- (c) 2026 Connor J. Link. All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.types.all;
use work.and_2.all;

entity multiplier is
    generic(
        constant N : natural := types.DATA_WIDTH,
        constant W : natural := 2*N
    );
    port(
        i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        o_P : out std_logic_vector(W-1 downto 0)
    );
end multiplier;

architecture implementation of multiplier is

    type t_word_array is array (natural range <>) of std_logic_vector(W-1 downto 0);

    -- Partial products (N rows), and accumulators (N+1 stages)
    signal s_PartialProducts  : t_word_array(0 to N-1);
    signal s_Accumulators : t_word_array(0 to N);

    signal s_Carry : std_logic_vector(0 to N);

begin

    s_Accumulators(0) <= (others => '0');
    s_Carry(0) <= '0';
    o_P <= s_Accumulators(N);

    g_PP_ROWS : for j in 0 to N-1 generate
        g_PP_BITS : for w in 0 to W-1 generate

            g_IN_RANGE : if (w >= j) and (w < (j + N)) generate
                ANDI : entity work.and_2
                    port map(
                        i_A => i_A(w - j),
                        i_B => i_B(j),
                        o_F => s_PartialProducts(j)(w)
                    );
            end generate g_IN_RANGE;

            g_OUT_RANGE : if not ((w >= j) and (w < (j + N))) generate
                s_PartialProducts(j)(w) <= '0';
            end generate g_OUT_RANGE;

        end generate g_PP_BITS;
    end generate g_PP_ROWS;


    g_ACCUMULATOR : for j in 0 to N-1 generate
        ADDN : entity work.adder_N
            generic map(
                N => W
            )
            port map(
                i_A     => s_Accumulators(j),
                i_B     => s_PartialProducts(j),
                i_Carry => '0',
                o_S     => s_Accumulators(j + 1),
                o_Carry => s_Carry(j + 1)
            );
    end generate g_ACCUMULATOR;

end implementation;