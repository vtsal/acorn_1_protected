-- =====================================================================
-- Copyright © 2016-2017 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.ACORN_pkg.all;
use work.design_pkg.all;

entity ACORN_Datapath is
    port(
        clk             : in  std_logic;
	    rst             : in  std_logic;
        key_a           : in  std_logic_vector(SW -1 downto 0);
        key_b           : in  std_logic_vector(SW -1 downto 0);
        bdi_a           : in  std_logic_vector(PW -1 downto 0);
        bdi_b           : in  std_logic_vector(PW -1 downto 0);
        bdo_a           : out std_logic_vector(PW -1 downto 0);
        bdo_b           : out std_logic_vector(PW -1 downto 0);
        rand            : in  std_logic_vector(RW -1 downto 0);
    --! Control
        en_KeyReg1      : in  std_logic;
        en_KeyReg2      : in  std_logic;
        L_KeyReg        : in  std_logic;
        rst_KeyReg      : in  std_logic;
        en_StateReg     : in  std_logic;
        rst_StateReg    : in  std_logic;
        en_bdiReg       : in  std_logic;
        L_bdiReg        : in  std_logic;
        en_bdoReg       : in  std_logic;
        ca_set          : in  std_logic;
        cb_set          : in  std_logic;
        sel_bdi         : in  std_logic;
        -- sel_LoadKey     : in  std_logic;
        is_final        : in  std_logic;
        sel_decrypt     : in  std_logic;
        tag_match       : out std_logic;
        sel_M           : in  std_logic_vector(2 downto 0)

        );

end entity ACORN_Datapath;

architecture dataflow of ACORN_Datapath is

    -- signal key_word        : std_logic_vector(M_SIZE       -1 downto 0);
    signal SReg_in_a       : std_logic_vector(STATE_SIZE   -1 downto 0);
    signal SReg_out_a      : std_logic_vector(STATE_SIZE   -1 downto 0);
    signal SReg_in_b       : std_logic_vector(STATE_SIZE   -1 downto 0);
    signal SReg_out_b      : std_logic_vector(STATE_SIZE   -1 downto 0);
    signal ca              : std_logic_vector(M_SIZE       -1 downto 0);
    signal cb              : std_logic_vector(M_SIZE       -1 downto 0);
    signal M_a             : std_logic_vector(M_SIZE       -1 downto 0);
    signal ks_a            : std_logic_vector(M_SIZE       -1 downto 0);
    signal M_b             : std_logic_vector(M_SIZE       -1 downto 0);
    signal ks_b            : std_logic_vector(M_SIZE       -1 downto 0);
    --signal KeyReg_Sin1     : std_logic_vector(SW           -1 downto 0);
    --signal KeyReg_Sin2     : std_logic_vector(M_SIZE       -1 downto 0);
    signal KeyReg_out_a    : std_logic_vector(PARAM_SIZE   -1 downto 0);
    signal KeyReg_out_b    : std_logic_vector(PARAM_SIZE   -1 downto 0);
    signal one_sig         : std_logic_vector(M_SIZE       -1 downto 0);
	signal zero_sig        : std_logic_vector(M_SIZE       -1 downto 0);

    signal keyR_din        : std_logic_vector(PARAM_SIZE   -1 downto 0);
    signal bdiReg_out_a    : std_logic_vector(PW           -1 downto 0);
    signal bdiReg_out_b    : std_logic_vector(PW           -1 downto 0);
    --signal bdoReg_out      : std_logic_vector(PW           -1 downto 0);
    signal bdi_s_a         : std_logic_vector(M_SIZE       -1 downto 0);
    signal bdo_s_a         : std_logic_vector(M_SIZE       -1 downto 0);
    signal bdi_s_b         : std_logic_vector(M_SIZE       -1 downto 0);
    signal bdo_s_b         : std_logic_vector(M_SIZE       -1 downto 0);

begin

--! ===================================================

--! ===================================================

    ShiftReg_key_a: entity work.shift_2sin(behavioral)
            generic map(
                    D_WIDTH  => PARAM_SIZE,
                    S1_WIDTH => SW,
                    S2_WIDTH => M_SIZE
            )
            port map(
                    d       => keyR_din,
                    en_s1   => en_KeyReg1,
                    en_s2   => en_KeyReg2,
                    load    => L_KeyReg,
                    sin1    => key_a,
                    sin2    => KeyReg_out_a(M_SIZE-1 downto 0),
                    clk     => clk,
                    rst     => rst_KeyReg,
                    q       => KeyReg_out_a
            );

    ShiftReg_key_b: entity work.shift_2sin(behavioral)
        generic map(
                D_WIDTH  => PARAM_SIZE,
                S1_WIDTH => SW,
                S2_WIDTH => M_SIZE
        )
        port map(
                d       => keyR_din,
                en_s1   => en_KeyReg1,
                en_s2   => en_KeyReg2,
                load    => L_KeyReg,
                sin1    => key_b,
                sin2    => KeyReg_out_b(M_SIZE-1 downto 0),
                clk     => clk,
                rst     => rst_KeyReg,
                q       => KeyReg_out_b
        );


    ShiftReg_bdi_a: entity work.shiftn(behavioral)
            generic map(
                    D_WIDTH => PW,
                    S_WIDTH => M_SIZE
            )
            port map(
                    d       => zero_sig & bdi_a(PW-1 downto M_SIZE),
                    enable  => en_bdiReg,
                    load    => L_bdiReg,
                    sin     => zero_sig,
                    clk     => clk,
                    rst     => rst_KeyReg,
                    q       => bdiReg_out_a
            );

    ShiftReg_bdi_b: entity work.shiftn(behavioral)
        generic map(
                D_WIDTH => PW,
                S_WIDTH => M_SIZE
        )
        port map(
                d       => zero_sig & bdi_b(PW-1 downto M_SIZE),
                enable  => en_bdiReg,
                load    => L_bdiReg,
                sin     => zero_sig,
                clk     => clk,
                rst     => rst_KeyReg,
                q       => bdiReg_out_b
        );

    ShiftReg_bdo_a: entity work.shiftn(behavioral)
            generic map(
                    D_WIDTH => PW,
                    S_WIDTH => M_SIZE
            )
            port map(
                    d       => X"00",
                    enable  => en_bdoReg,
                    load    => '0',
                    sin     => bdo_s_a,
                    clk     => clk,
                    rst     => rst_KeyReg,
                    q       => bdo_a
            );

    ShiftReg_bdo_b: entity work.shiftn(behavioral)
        generic map(
                D_WIDTH => PW,
                S_WIDTH => M_SIZE
        )
        port map(
                d       => X"00",
                enable  => en_bdoReg,
                load    => '0',
                sin     => bdo_s_b,
                clk     => clk,
                rst     => rst_KeyReg,
                q       => bdo_b
        );

    State_Reg_a: entity work.Register_s(behavioral)
                generic map(N => STATE_SIZE)
                port map(
                        d       => SReg_in_a,
                        enable  => en_StateReg,
                        reset   => rst_StateReg,
                        clock   => clk,
                        q       => SReg_out_a
                );

    State_Reg_b: entity work.Register_s(behavioral)
                generic map(N => STATE_SIZE)
                port map(
                        d       => SReg_in_b,
                        enable  => en_StateReg,
                        reset   => rst_StateReg,
                        clock   => clk,
                        q       => SReg_out_b
                );

    State_Update: entity work.ACORN_StateUpdate(behavior)
        port map(
            clk     => clk,
            rand    => rand,
            s_in_a  => SReg_out_a,
            s_in_b  => SReg_out_b,
            m_a     => M_a,
            m_b     => M_b,
            ca      => ca,
            cb      => cb,
            is_final=> is_final,
            sel_decrypt => sel_decrypt,
            s_out_a => SReg_in_a,
            s_out_b => SReg_in_b,
            ks_out_a  => ks_a,
            ks_out_b  => ks_b
        );


--! ===================================================

--! ===================================================
    bdi_s_a  <= bdi_a(M_SIZE -1 downto 0) when sel_bdi = '1' else
        bdiReg_out_a(M_SIZE -1 downto 0);
    bdi_s_b  <= bdi_b(M_SIZE -1 downto 0) when sel_bdi = '1' else
        bdiReg_out_b(M_SIZE -1 downto 0);
    one_sig     <= (0 => '1', others => '0');
	zero_sig    <= (others => '0');
    ca          <= (others => '1') when ca_set = '1' else (others => '0');
    cb          <= (others => '1') when cb_set = '1' else (others => '0');
    --KeyReg_Sin  <= key when (sel_LoadKey = '1') else KeyReg_out(M_SIZE-1 downto 0);

    with sel_M select M_a <=
        KeyReg_out_a(M_SIZE-1 downto 0) when "000",
        (KeyReg_out_a(M_SIZE-1 downto 0)) when "001",--xor one_sig
        bdi_s_a  when "010",
		--one_sig  when "011",
		zero_sig when others;

    with sel_M select M_b <=
        KeyReg_out_b(M_SIZE-1 downto 0) when "000",
        (KeyReg_out_b(M_SIZE-1 downto 0) xor one_sig) when "001",
        bdi_s_b  when "010",
		one_sig  when "011",
		zero_sig when others;

    --tag_match <= '1' when ((bdi_s_b xor bdi_s_a) = (ks_a xor ks_b)) else '0';
    --tag_match <= '1' when (bdi_s = ks) else '0';
    tag_match <= '1'; 

    bdo_s_a <= ks_a;
    bdo_s_b <= ks_b;


end dataflow;
