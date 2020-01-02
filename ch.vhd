-- =====================================================================
-- Copyright © 2016-2017 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- Author: Farnoud Farahmand
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;

entity ch is

    port(
        --clk    : in std_logic;
        x_a    : in std_logic;
        x_b    : in std_logic;
        y_a    : in std_logic;
        y_b    : in std_logic;
        z_a    : in std_logic;
        z_b    : in std_logic;
        m      : in std_logic_vector(5 downto 0);
        o_a    : out std_logic;
        o_b    : out std_logic
    );

end ch;

architecture structure of ch is

signal x_and_y_a, x_and_y_b: std_logic;
signal nx_and_z_a, nx_and_z_b: std_logic;
--signal o_a_s, o_b_s : std_logic;

begin

and_3Ti_1: entity work.and_3TI(structural)
    port map(
        xa => x_a,
        xb => x_b,
        ya => y_a,
        yb => y_b,
        m  => m(5 downto 3),
        o1 => x_and_y_a,
        o2 => x_and_y_b
    );

and_3Ti_2: entity work.and_3TI(structural)
    port map(
        xa => (x_a),--not(x_a)
        xb => not(x_b),
        ya => z_a,
        yb => z_b,
        m  => m(2 downto 0),
        o1 => nx_and_z_a,
        o2 => nx_and_z_b
    );


o_a <= x_and_y_a xor nx_and_z_a;
o_b <= x_and_y_b xor nx_and_z_b;

--reg: process(clk)
--begin
--    if rising_edge(clk) then
--            o_a <= o_a_s;
--            o_b <= o_b_s;
--    end if;
--end process;

end structure;
