-- =====================================================================
-- Copyright © 2016-2017 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
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
        sel_M           : in  std_logic_vector(2 downto 0);
        
        -- Added by Behnaz ------------------------------------
        --=====================================================
        e_tag_en       : in std_logic;
        e_tag_rst      : in std_logic;
        c_tag_en       : in std_logic;
        c_tag_rst      : in std_logic;
        raReg_en       : in std_logic;
        rbReg_en       : in std_logic;
        c1a_en         : in std_logic;
        c2a_en         : in std_logic;
        c1b_en         : in std_logic;
        c2b_en         : in std_logic;
        d1a_en         : in std_logic;
        d2a_en         : in std_logic;
        d1b_en         : in std_logic;
        d2b_en         : in std_logic
        --=====================================================

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
    
    -- Added by Behnaz ----------------------------------------------------------------------------
    --=============================================================================================
    signal e_tag_a_in       : std_logic_vector(127 downto 0);    -- Expected Tag a
    signal e_tag_a_out      : std_logic_vector(127 downto 0);
    signal e_tag_b_in       : std_logic_vector(127 downto 0);    -- Expected Tag b
    signal e_tag_b_out      : std_logic_vector(127 downto 0);
    signal c_tag_a_in       : std_logic_vector(127 downto 0);    -- Computed Tag a
    signal c_tag_a_out      : std_logic_vector(127 downto 0);
    signal c_tag_b_in       : std_logic_vector(127 downto 0);    -- Computed Tag b
    signal c_tag_b_out      : std_logic_vector(127 downto 0);
    
    signal ra, rb           : std_logic_vector(63 downto 0);  
    signal c1a_in, c1a_out  : std_logic_vector(63 downto 0);
    signal c2a_in, c2a_out  : std_logic_vector(63 downto 0);
    signal c1b_in, c1b_out  : std_logic_vector(63 downto 0);
    signal c2b_in, c2b_out  : std_logic_vector(63 downto 0);
    signal d1a_in, d1a_out  : std_logic_vector(63 downto 0);
    signal d2a_in, d2a_out  : std_logic_vector(63 downto 0);
    signal d1b_in, d1b_out  : std_logic_vector(63 downto 0);
    signal d2b_in, d2b_out  : std_logic_vector(63 downto 0);
    
    signal ShiftReg_d_a     : std_logic_vector(PW downto M_SIZE);
    signal ShiftReg_d_b     : std_logic_vector(PW downto M_SIZE);
    
    --signal tag              : std_logic_vector(127 downto 0);
    --=============================================================================================

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

    ShiftReg_d_a <= zero_sig & bdi_a(PW-1 downto M_SIZE); -- Added by Behnaz
    ShiftReg_bdi_a: entity work.shiftn(behavioral)
            generic map(
                    D_WIDTH => PW,
                    S_WIDTH => M_SIZE
            )
            port map(
                    d       => ShiftReg_d_a, -- Added by Behnaz
                    enable  => en_bdiReg,
                    load    => L_bdiReg,
                    sin     => zero_sig,
                    clk     => clk,
                    rst     => rst_KeyReg,
                    q       => bdiReg_out_a
            );

    ShiftReg_d_b <= zero_sig & bdi_b(PW-1 downto M_SIZE); -- Added by Behnaz
    ShiftReg_bdi_b: entity work.shiftn(behavioral)
        generic map(
                D_WIDTH => PW,
                S_WIDTH => M_SIZE
        )
        port map(
                d       => ShiftReg_d_b, -- Added by Behnaz
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
        
     --tag <= c_tag_a_out xor c_tag_b_out;

    --- Added by Behnaz ---------------------------------------------------------------------------
    --=============================================================================================
    e_tag_a_in <= bdi_a & e_tag_a_out(127 downto 8);
    eTagReg_a: entity work.Register_s(behavioral) -- Expected Tag a
    generic map(N => 128)
    Port map(
        clock   => clk,
        enable  => e_tag_en,
        reset   => e_tag_rst,
        d       => e_tag_a_in,
        q       => e_tag_a_out
    );
    
    e_tag_b_in <= bdi_b & e_tag_b_out(127 downto 8);
    eTagReg_b: entity work.Register_s(behavioral) -- Expected Tag b
    generic map(N => 128)
    Port map(
        clock   => clk,
        enable  => e_tag_en,
        reset   => e_tag_rst,
        d       => e_tag_b_in,
        q       => e_tag_b_out
    );
    
    c_tag_a_in <= ks_a & c_tag_a_out(127 downto 1);
    cTagReg_a: entity work.Register_s(behavioral) -- Computed Tag a
    generic map(N => 128)
    Port map(
        clock   => clk,
        enable  => c_tag_en,
        reset   => c_tag_rst,
        d       => c_tag_a_in,
        q       => c_tag_a_out
    );
    
    c_tag_b_in <= ks_b & c_tag_b_out(127 downto 1);
    cTagReg_b: entity work.Register_s(behavioral) -- Computed Tag b
    generic map(N => 128)
    Port map(
        clock   => clk,
        enable  => c_tag_en,
        reset   => c_tag_rst,
        d       => c_tag_b_in,
        q       => c_tag_b_out
    );
    
    raReg: entity work.Register_s(behavioral) -- Register random share for 64-MSB of the Tag
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => raReg_en,
        reset   => '0',
        d       => rand,
        q       => ra
    );
    
    rbReg: entity work.Register_s(behavioral) -- Register random share for 64-LSB of the Tag
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => rbReg_en,
        reset   => '0',
        d       => rand,
        q       => rb
    );
    
    c1a_in      <= c_tag_a_out(127 downto 64) xor e_tag_a_out(127 downto 64);
    c1aReg: entity work.Register_s(behavioral) 
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => c1a_en,
        reset   => '0',
        d       => c1a_in,
        q       => c1a_out
    );
    
    c2a_in      <= c_tag_b_out(127 downto 64) xor e_tag_b_out(127 downto 64);       
    c2aReg: entity work.Register_s(behavioral)
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => c2a_en,
        reset   => '0',
        d       => c2a_in,
        q       => c2a_out
    );
    
    c1b_in      <= c_tag_a_out(63 downto 0) xor e_tag_a_out(63 downto 0);
    c1bReg: entity work.Register_s(behavioral)
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => c1b_en,
        reset   => '0',
        d       => c1b_in,
        q       => c1b_out
    );
      
    c2b_in      <= c_tag_b_out(63 downto 0) xor e_tag_b_out(63 downto 0);
    c2bReg: entity work.Register_s(behavioral)
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => c2b_en,
        reset   => '0',
        d       => c2b_in,
        q       => c2b_out
    );

    d1a_in      <= c1a_out xor c2a_out xor ra;
    d1aReg: entity work.Register_s(behavioral)
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => d1a_en,
        reset   => '0',
        d       => d1a_in,
        q       => d1a_out
    );
    
    d2a_in      <=  d1a_out xor ra;
    d2aReg: entity work.Register_s(behavioral)
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => d2a_en,
        reset   => '0',
        d       => d2a_in,
        q       => d2a_out
    );
    
    d1b_in      <= c1b_out xor c2b_out xor rb;
    d1bReg: entity work.Register_s(behavioral)
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => d1b_en,
        reset   => '0',
        d       => d1b_in,
        q       => d1b_out
    ); 
    
    d2b_in      <= d1b_out xor rb;
    d2bReg: entity work.Register_s(behavioral)
    generic map(N => 64)
    Port map(
        clock   => clk,
        enable  => d2b_en,
        reset   => '0',
        d       => d2b_in,
        q       => d2b_out
    ); 
    --=============================================================================================


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
    --tag_match <= '1'; 
    
    -- Added by Behnaz ---------------------------------------------------------
    --==========================================================================
    tag_match <= '1' when ((d2a_out = 0) and (d2b_out = 0)) else '0';
    --==========================================================================

    bdo_s_a <= ks_a;
    bdo_s_b <= ks_b;


end dataflow;
