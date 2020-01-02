-- =====================================================================
-- Copyright © 2016-2017 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- Author: Farnoud Farahmand
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;

entity KSG128 is

    port(
        clk     : in std_logic;
        S_12_a  : in std_logic;
        S_12_b  : in std_logic;
        S_154_a : in std_logic;
        S_154_b : in std_logic;
        S_235_a : in std_logic;
        S_235_b : in std_logic;
        S_61_a  : in std_logic;
        S_61_b  : in std_logic;
        S_193_a : in std_logic;
        S_193_b : in std_logic;
        S_230_a : in std_logic;
        S_230_b : in std_logic;
        S_111_a : in std_logic;
        S_111_b : in std_logic;
        S_66_a  : in std_logic;
        S_66_b  : in std_logic;
        m       : in std_logic_vector(14 downto 0);
        o_a     : out std_logic;
        o_b     : out std_logic
    );

end KSG128;

architecture structure of KSG128 is

signal maj_a, maj_b: std_logic;
signal ch_a, ch_b: std_logic;
signal o_a_s, o_b_s : std_logic;

begin

maj: entity work.maj(structure)
    port map(
        --clk => clk,
        x_a  => S_235_a,
        x_b  => S_235_b,
        y_a  => S_61_a,
        y_b  => S_61_b,
        z_a  => S_193_a,
        z_b  => S_193_b,
        m   => m(14 downto 6),
        o_a => maj_a,
        o_b => maj_b
    );

ch: entity work.ch(structure)
    port map(
        --clk => clk,
        x_a  => S_230_a,
        x_b  => S_230_b,
        y_a  => S_111_a,
        y_b  => S_111_b,
        z_a  => S_66_a,
        z_b  => S_66_b,
        m   => m(5 downto 0),
        o_a => ch_a,
        o_b => ch_b
    );


o_a_s <= S_12_a xor S_154_a xor maj_a xor ch_a;
o_b_s <= S_12_b xor S_154_b xor maj_b xor ch_b;

reg: process(clk)
begin
    if rising_edge(clk) then
            o_a <= o_a_s;
            o_b <= o_b_s;
    end if;
end process;

end structure;
