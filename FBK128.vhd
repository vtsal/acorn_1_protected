-- =====================================================================
-- Copyright © 2016-2017 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- Author: Farnoud Farahmand
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;

entity FBK128 is

    port(
        clk     : in std_logic;
        S_0_a   : in std_logic;
        S_0_b   : in std_logic;
        S_107_a : in std_logic;
        S_107_b : in std_logic;
        S_244_a : in std_logic;
        S_244_b : in std_logic;
        S_23_a  : in std_logic;
        S_23_b  : in std_logic;
        S_160_a : in std_logic;
        S_160_b : in std_logic;
        S_196_a : in std_logic;
        S_196_b : in std_logic;
        ca      : in std_logic;
        cb      : in std_logic;
        ks_a    : in std_logic;
        ks_b    : in std_logic;
        m       : in std_logic_vector(14 downto 0);
        o_a     : out std_logic;
        o_b     : out std_logic
    );

end FBK128;

architecture structure of FBK128 is

signal maj_a, maj_b : std_logic;
signal ca_and_S196_a, ca_and_S196_b : std_logic;
signal cb_and_ks_a, cb_and_ks_b : std_logic;

begin

maj: entity work.maj(structure)
    port map(
        --clk => clk,
        x_a  => S_244_a,
        x_b  => S_244_b,
        y_a  => S_23_a,
        y_b  => S_23_b,
        z_a  => S_160_a,
        z_b  => S_160_b,
        m   => m(14 downto 6),
        o_a => maj_a,
        o_b => maj_b
    );

and_3Ti_1: entity work.and_3TI(structural)
    port map(
        xa => '0',--ca,
        xb => ca,
        ya => S_196_a,
        yb => S_196_b,
        m  => m(5 downto 3),
        o1 => ca_and_S196_a,
        o2 => ca_and_S196_b
    );

and_3Ti_2: entity work.and_3TI(structural)
    port map(
        xa => '0',--cb,
        xb => cb,
        ya => ks_a,
        yb => ks_b,
        m  => m(2 downto 0),
        o1 => cb_and_ks_a,
        o2 => cb_and_ks_b
    );

o_a <= S_0_a xor (S_107_a) xor maj_a xor ca_and_S196_a xor cb_and_ks_a; --not S_107_a
o_b <= S_0_b xor (not S_107_b) xor maj_b xor ca_and_S196_b xor cb_and_ks_b;

end structure;
