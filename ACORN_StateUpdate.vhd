-- =====================================================================
-- Copyright © 2016-2017 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- Author: Farnoud Farahmand
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.ACORN_pkg.all;
use work.design_pkg.all;

entity ACORN_StateUpdate is

    port(
        clk     : in std_logic;
        rand    : in std_logic_vector(RW -1 downto 0);
        s_in_a  : in std_logic_vector(STATE_SIZE-1 downto 0);
        s_in_b  : in std_logic_vector(STATE_SIZE-1 downto 0);
        m_a     : in std_logic_vector(M_SIZE-1 downto 0);
        m_b     : in std_logic_vector(M_SIZE-1 downto 0);
        ca      : in std_logic_vector(M_SIZE-1 downto 0);
        cb      : in std_logic_vector(M_SIZE-1 downto 0);
        is_final    : in std_logic;
        sel_decrypt : in std_logic;

        s_out_a  : out std_logic_vector(STATE_SIZE-1 downto 0);
        s_out_b  : out std_logic_vector(STATE_SIZE-1 downto 0);
        ks_out_a : out std_logic_vector(M_SIZE-1 downto 0);
        ks_out_b : out std_logic_vector(M_SIZE-1 downto 0)
    );

end ACORN_StateUpdate;

architecture behavior of ACORN_StateUpdate is

    signal s_a, s1_a  : std_logic_vector(M_SIZE+STATE_SIZE-1 downto 0);
    signal s_b, s1_b  : std_logic_vector(M_SIZE+STATE_SIZE-1 downto 0);
    signal ks_a, f_a, new_blk_a, msg_a, ks_s_a  : std_logic_vector(M_SIZE-1 downto 0);
    signal ks_b, f_b, new_blk_b, msg_b, ks_s_b  : std_logic_vector(M_SIZE-1 downto 0);
    signal zero_sig  : std_logic_vector(M_SIZE-1 downto 0);

begin

    zero_sig    <= (others => '0');
    s_a   <= zero_sig & s_in_a(STATE_SIZE-1 downto 0);
    s_b   <= zero_sig & s_in_b(STATE_SIZE-1 downto 0);
    msg_a <= (m_a xor ks_a) when sel_decrypt='1' else m_a;
    msg_b <= (m_b xor ks_b) when sel_decrypt='1' else m_b;

    s1_a(M_SIZE+STATE_SIZE-1 downto 289+M_SIZE)  <=  s_a(M_SIZE+STATE_SIZE-1 downto 289+M_SIZE);
    s1_a(288                 downto 230+M_SIZE)  <=  s_a(288                 downto 230+M_SIZE);
    s1_a(229                 downto 193+M_SIZE)  <=  s_a(229                 downto 193+M_SIZE);
    s1_a(192                 downto 154+M_SIZE)  <=  s_a(192                 downto 154+M_SIZE);
    s1_a(153                 downto 107+M_SIZE)  <=  s_a(153                 downto 107+M_SIZE);
    s1_a(106                 downto 61 +M_SIZE)  <=  s_a(106                 downto 61 +M_SIZE);
    s1_a(60                  downto 0)           <=  s_a(60                  downto 0);

    s1_b(M_SIZE+STATE_SIZE-1 downto 289+M_SIZE)  <=  s_b(M_SIZE+STATE_SIZE-1 downto 289+M_SIZE);
    s1_b(288                 downto 230+M_SIZE)  <=  s_b(288                 downto 230+M_SIZE);
    s1_b(229                 downto 193+M_SIZE)  <=  s_b(229                 downto 193+M_SIZE);
    s1_b(192                 downto 154+M_SIZE)  <=  s_b(192                 downto 154+M_SIZE);
    s1_b(153                 downto 107+M_SIZE)  <=  s_b(153                 downto 107+M_SIZE);
    s1_b(106                 downto 61 +M_SIZE)  <=  s_b(106                 downto 61 +M_SIZE);
    s1_b(60                  downto 0)           <=  s_b(60                  downto 0);

    Gen_State: for i in 0 to M_SIZE-1 generate

        s1_a(289+i) <= s_a(289+i) xor s_a(235+i) xor s_a(230+i);
        s1_a(230+i) <= s_a(230+i) xor s_a(196+i) xor s_a(193+i);
        s1_a(193+i) <= s_a(193+i) xor s_a(160+i) xor s_a(154+i);
        s1_a(154+i) <= s_a(154+i) xor s_a(111+i) xor s_a(107+i);
        s1_a(107+i) <= s_a(107+i) xor s_a(66 +i) xor s_a(61 +i);
        s1_a(61 +i) <= s_a(61 +i) xor s_a(23 +i) xor s_a(0  +i);

        s1_b(289+i) <= s_b(289+i) xor s_b(235+i) xor s_b(230+i);
        s1_b(230+i) <= s_b(230+i) xor s_b(196+i) xor s_b(193+i);
        s1_b(193+i) <= s_b(193+i) xor s_b(160+i) xor s_b(154+i);
        s1_b(154+i) <= s_b(154+i) xor s_b(111+i) xor s_b(107+i);
        s1_b(107+i) <= s_b(107+i) xor s_b(66 +i) xor s_b(61 +i);
        s1_b(61 +i) <= s_b(61 +i) xor s_b(23 +i) xor s_b(0  +i);

        KSG128: entity work.KSG128(structure)
        port map(
            clk      => clk,
            S_12_a   => s_a(12 +i),
            S_12_b   => s_b(12 +i),
            S_154_a  => s1_a(154+i),
            S_154_b  => s1_b(154+i),
            S_235_a  => s_a(235+i),
            S_235_b  => s_b(235+i),
            S_61_a   => s1_a(61 +i),
            S_61_b   => s1_b(61 +i),
            S_193_a  => s1_a(193+i),
            S_193_b  => s1_b(193+i),
            S_230_a  => s1_a(230+i),
            S_230_b  => s1_b(230+i),
            S_111_a  => s_a(111+i),
            S_111_b  => s_b(111+i),
            S_66_a   => s_a(66 +i),
            S_66_b   => s_b(66 +i),
            --m        => rand((30*i)+15-1 downto 30*i),
            m        => rand((15*i)+15-1 downto 15*i),
            o_a      => ks_a(i),
            o_b      => ks_b(i)
        );

        FBK128: entity work.FBK128(structure)
        port map(
            clk      => clk,
            S_0_a    => s_a(0  +i),
            S_0_b    => s_b(0  +i),
            S_107_a  => s1_a(107+i),
            S_107_b  => s1_b(107+i),
            S_244_a  => s_a(244+i),
            S_244_b  => s_b(244+i),
            S_23_a   => s_a(23 +i),
            S_23_b   => s_b(23 +i),
            S_160_a  => s_a(160+i),
            S_160_b  => s_b(160+i),
            S_196_a  => s_a(196+i),
            S_196_b  => s_b(196+i),
            ca       => ca(i),
            cb       => cb(i),
            ks_a     => ks_a(i),
            ks_b     => ks_b(i),
            --m        => rand((30*i)+30-1 downto (30*i)+15),
            m        => rand((15*i)+15-1 downto 15*i),
            o_a      => f_a(i),
            o_b      => f_b(i)
        );

        new_blk_a(i) <= f_a(i) xor msg_a(i) xor s1_a(STATE_SIZE + i);
        new_blk_b(i) <= f_b(i) xor msg_b(i) xor s1_b(STATE_SIZE + i);

    end generate Gen_State;

    s_out_a  <= new_blk_a & s1_a(STATE_SIZE-1 downto M_SIZE);
    s_out_b  <= new_blk_b & s1_b(STATE_SIZE-1 downto M_SIZE);

    ks_out_a <= ks_a when (is_final = '1') else (ks_a xor m_a);
    ks_out_b <= ks_b when (is_final = '1') else (ks_b xor m_b);

end behavior;
