-- =====================================================================
-- Copyright © 2016-2017 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.ACORN_pkg.all;
use work.AEAD_pkg.all;
use IEEE.math_real."ceil";
use IEEE.math_real."log2";
use work.CAESAR_LWAPI_pkg.all;
use work.design_pkg.all;

entity ACORN_Control is
    port(
        --! Global
        clk             : in  std_logic;
        rst             : in  std_logic;
        --! PreProcessor (controls)
        key_ready       : out std_logic;
        --key_r_ready     : out std_logic;
        key_valid       : in  std_logic;
        key_update      : in  std_logic;
        decrypt         : in  std_logic;
        bdi_ready       : out std_logic;
        bdi_valid       : in  std_logic;
        bdi_type        : in  std_logic_vector(4                -1 downto 0);
        bdi_eot         : in  std_logic;
        bdi_eoi         : in  std_logic;
        --! PostProcessor
        bdo             : out std_logic_vector(8      -1 downto 0);
        bdo_valid       : out std_logic;
        bdo_ready       : in  std_logic;
        msg_auth        : out std_logic;
        msg_auth_valid  : out std_logic;
        msg_auth_ready  : in  std_logic;
		bdo_valid_bytes : out  STD_LOGIC_VECTOR (PWdiv8   -1 downto 0);
        bdo_type        : out  STD_LOGIC_VECTOR (4       -1 downto 0);

        --! Control
        en_KeyReg1      : out  std_logic;
        en_KeyReg2      : out  std_logic;
        L_KeyReg        : out  std_logic;
        rst_KeyReg      : out  std_logic;
        en_StateReg     : out  std_logic;
        rst_StateReg    : out  std_logic;
        en_bdiReg       : out  std_logic;
        L_bdiReg        : out  std_logic;
        en_bdoReg       : out  std_logic;
        ca_set          : out  std_logic;
        cb_set          : out  std_logic;
        -- sel_LoadKey     : out  std_logic;
        sel_bdi         : out  std_logic;
        is_final        : out  std_logic;
        sel_decrypt     : out  std_logic;
        tag_match       : in   std_logic;
        -- done            : out  std_logic;
        sel_M           : out  std_logic_vector(2 downto 0);
        end_of_block    : out std_logic;
        rdi_valid       : in  std_logic;
        rdi_ready       : out std_logic
    );

end entity ACORN_Control;

architecture behavioral of ACORN_Control is

    type t_state is(
                    S_RESET, S_WAIT_START, S_WAIT_KEY, S_INIT_KEY, S_INIT_NPUB,
                    S_INIT_KEY2, S_PROC_AD, S_PROC_ADPAD1, S_PROC_ADPAD0,
                    S_PROC_PT, S_PROC_DATPAD1, S_PROC_DATPAD0, S_FINAL,
                    S_WAIT_MSG_AUTH, S_INIT_NPUB1, S_PROC_AD1, S_PROC_PT1,
                    S_PROC_PT2, S_FINAL1_DEC
                );
    signal state       : t_state;
    signal state_next  : t_state;
    signal count_r     : std_logic_vector(10 downto 0);
    signal count_next  : std_logic_vector(10 downto 0);
    signal eoi_r       : std_logic;
    signal eoi_next    : std_logic;
    signal auth_fail_next   : std_logic;
    signal auth_fail_r      : std_logic;
    signal first_block_next : std_logic;
    signal first_block_r    : std_logic;
    signal wait_r          : std_logic;
    signal wait_next       : std_logic;
    signal decrypt_r       : std_logic;
    signal en_decrypt      : std_logic;
    signal eot_r           : std_logic;
    signal en_eot          : std_logic;

begin

    p_fsm: process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                state <= S_RESET;
            else
                state       <= state_next;
            end if;
            count_r         <= count_next;
            eoi_r           <= eoi_next;
            auth_fail_r     <= auth_fail_next;
            first_block_r   <= first_block_next;
            wait_r          <= wait_next;
            if en_decrypt='1' then
                decrypt_r   <= decrypt;
            end if;
            if en_eot ='1' then
                eot_r   <= bdi_eot;
            end if;
        end if;
    end process;

    p_comb: process(state, count_r, bdi_valid, key_valid, bdi_eoi, eoi_r,
                    bdi_type, bdi_eot, bdo_ready, decrypt_r, tag_match,
                    auth_fail_r, msg_auth_ready, eot_r, first_block_r, wait_r,
                    rdi_valid)
    begin
        --! Default values
        state_next  <= state;
        count_next  <= count_r;
        eoi_next    <= eoi_r;
        auth_fail_next    <= auth_fail_r;
        first_block_next  <= first_block_r;
        wait_next   <= wait_r;

        en_KeyReg1      <= '0';
        en_KeyReg2      <= '0';
        L_KeyReg        <= '0';
        rst_KeyReg      <= '0';
        en_StateReg     <= '0';
        rst_StateReg    <= '0';
        en_bdiReg       <= '0';
        L_bdiReg        <= '0';
        en_bdoReg       <= '0';
        ca_set          <= '0';
        cb_set          <= '0';
        -- sel_LoadKey     <= '0';
        sel_bdi         <= '0';
        is_final        <= '0';
        sel_decrypt     <= '0';
        sel_M           <= "000";

        --! External
        key_ready      <= '0';
        --key_r_ready <= '0';
        bdi_ready      <= '0';
        bdo_valid      <= '0';
        msg_auth       <= '0';
        msg_auth_valid <= '0';
        en_decrypt     <= '0';
        en_eot         <= '0';
        --done           <= '0';
        end_of_block   <= '0';
        rdi_ready      <= '0';

		bdo_valid_bytes<=(others=>'1');

        case state is

            when S_RESET =>
                state_next		<= S_WAIT_START;
                count_next	 	<= (others => '0');
				rst_StateReg	<= '1';
                auth_fail_next  <= '0';
                wait_next   	<= '0';

            when S_WAIT_START =>
                -- if (bdi_valid = '1') then
                    -- if (key_update = '1') then
                        -- state_next <= S_WAIT_KEY;
                    -- else
                        -- count_next  <= (others => '0');
                        -- ca_set      <= '1';
                        -- cb_set      <= '1';
						-- rst_StateReg	<= '1';
                        -- state_next      <= S_INIT_KEY;
                    -- end if;
                -- end if;
                --state_next <= S_WAIT_KEY;
                if key_valid='1' then
                    state_next <= S_WAIT_KEY;
                elsif bdi_valid='1' then
                    count_next  <= (others => '0');
                    ca_set      <= '1';
                    cb_set      <= '1';
                    rst_StateReg	<= '1';
                    state_next <= S_INIT_KEY;
                else
                    state_next      <= S_WAIT_START;
                end if;

            when S_WAIT_KEY =>
                key_ready   <= '1';
                -- sel_LoadKey <= '1';
                if (key_valid = '1') then
                    en_KeyReg1   <= '1';
                    if (count_r = PARAM_SIZE/PW -1) then
                        count_next  <= (others => '0');
                        state_next  <= S_INIT_KEY;
                    else
                        count_next  <= count_r + 1;
                    end if;
                end if;

            when S_INIT_KEY =>
                -- en_KeyReg2  <= '1';
                -- en_StateReg <= '1';
				ca_set      <= '1';
				cb_set      <= '1';
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        en_KeyReg2  <= '1';
                        en_StateReg <= '1';
                        if (count_r = PdivM-1) then
                            count_next  <= (others => '0');
                            state_next  <= S_INIT_NPUB;
                        else
                            count_next  <= count_r + 1;
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

			when S_INIT_NPUB =>
				sel_M		<= "010";
				ca_set      <= '1';
				cb_set      <= '1';
                sel_bdi     <= '1';
				-- bdi_ready   <= '1';
                if (rdi_valid = '1') then
    				if (bdi_valid = '1') then
                        rdi_ready   <= '1';
                        if (wait_r = '1') then
                            bdi_ready    <= '1';
                            wait_next    <= '0';
                            L_bdiReg     <= '1';
                            en_bdiReg    <= '1';
                            en_StateReg	 <= '1';
                            count_next   <= count_r + 1;
                            state_next   <= S_INIT_NPUB1;
                            if (count_r = PARAM_SIZE-PW) then
                                eoi_next    <= bdi_eoi;
                                en_decrypt  <= '1';
                            end if;
                        else
                            wait_next   <= '1';
                        end if;
                    end if;
                end if;

            when S_INIT_NPUB1 =>
                sel_M		<= "010";
                ca_set      <= '1';
                cb_set      <= '1';
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next    <= '0';
                        en_StateReg	 <= '1';
                        en_bdiReg    <= '1';
                        if (count_r = PdivM-1) then
                            state_next  <= S_INIT_KEY2;
                            count_next  <= (others => '0');
                        elsif (count_r(2 downto 0) = "111") then
                            state_next  <= S_INIT_NPUB;
                            count_next  <= count_r + 1;
                        else
                            count_next  <= count_r + 1;
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

			when S_INIT_KEY2 =>
				ca_set      <= '1';
				cb_set      <= '1';
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        if (count_r = 0) then
                            sel_M		<= "001";
                            en_StateReg <= '1';
                            en_KeyReg2	<= '1';
                            count_next  <= count_r + 1;
                        elsif (count_r <= INIT_COUNT) then
                            sel_M		<= "000";
                            en_StateReg <= '1';
                            en_KeyReg2	<= '1';
                            count_next  <= count_r + 1;
                        else
                            count_next  <= (others => '0');
                            if (eoi_r = '1') then
                                state_next  <= S_PROC_ADPAD1;
                            else
                                state_next  <= S_PROC_AD;
                            end if;
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

			when S_PROC_AD =>
                sel_bdi   <= '1';
                if (rdi_valid = '1') then
                    if (bdi_valid = '1') then
                        rdi_ready   <= '1';
                        if (wait_r = '1') then
                            wait_next   <= '0';
                            if (bdi_type = HDR_AD) then
                                bdi_ready    <= '1';
                                ca_set       <= '1';
                                cb_set       <= '1';
                                sel_M	 	 <= "010";
                                en_StateReg  <= '1';
                                L_bdiReg     <= '1';
                                en_bdiReg    <= '1';
                                en_eot       <= '1';
                                count_next   <= count_r + 1;
                                state_next   <= S_PROC_AD1;
                                if (bdi_eot = '1') then
                                    eoi_next   <= bdi_eoi;
                                end if;
                            else
                                ca_set      <= '1';
                                cb_set      <= '1';
                                sel_M		<= "011";
                                en_StateReg <= '1';
                                count_next  <= count_r + 1;
                                state_next  <= S_PROC_ADPAD0;
                            end if;
                        else
                            wait_next   <= '1';
                        end if;
                    end if;
                end if;

            when S_PROC_AD1 =>
                sel_M	 	 <= "010";
                ca_set       <= '1';
                cb_set       <= '1';
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        en_StateReg  <= '1';
                        en_bdiReg    <= '1';
                        if (count_r = PW/M_SIZE -1) then
                            count_next  <= (others => '0');
                            if (eot_r = '1') then
                                state_next <= S_PROC_ADPAD1;
                            else
                                state_next <= S_PROC_AD;
                            end if;
                        else
                            count_next  <= count_r + 1;
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_PROC_ADPAD1 =>
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        ca_set      <= '1';
                        cb_set      <= '1';
                        sel_M		<= "011";
                        en_StateReg <= '1';
                        count_next  <= count_r + 1;
                        state_next  <= S_PROC_ADPAD0;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_PROC_ADPAD0 =>
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        sel_M		<= "100";
                        en_StateReg <= '1';
                        if (count_r <= PdivM-1) then
                            ca_set      <= '1';
                            cb_set      <= '1';
                        elsif (count_r <= (PdivM_X2)-1) then
                            cb_set      <= '1';
                        end if;
                        if (count_r = (PdivM_X2)-1) then
                            count_next  <= (others => '0');
                            if (eoi_r = '1') then
                                state_next      <= S_PROC_DATPAD1;
                            else
                                first_block_next <= '1';
                                state_next       <= S_PROC_PT;
                            end if;
                        else
                            count_next  <= count_r + 1;
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_PROC_PT =>
                sel_bdi   <= '1';
                if (bdo_ready = '1') and (bdi_valid = '1') and (rdi_valid = '1')then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        L_bdiReg     <= '1';
                        en_bdiReg    <= '1';
                        en_bdoReg    <= '1';
                        --bdo_valid    <= '1';
                        bdi_ready    <= '1';
                        ca_set       <= '1';
                        sel_M		 <= "010";
                        sel_decrypt  <= decrypt_r;
                        en_StateReg  <= '1';
                        en_eot       <= '1';
                        --if (bdi_eot = '1') then
                        --    state_next  <= S_PROC_DATPAD1;
                        --    end_of_block <= '1';
                        --end if;
                        first_block_next <= '0';
                        count_next  <= count_r + 1;
                        state_next  <= S_PROC_PT1;
                        if (first_block_r = '0') then
                            bdo_valid    <= '1';
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_PROC_PT1 =>
                sel_M		 <= "010";
                ca_set       <= '1';
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        en_bdiReg    <= '1';
                        en_bdoReg    <= '1';
                        en_StateReg  <= '1';
                        sel_decrypt  <= decrypt_r;
                        if (count_r = PW/M_SIZE -1) then
                            count_next  <= (others => '0');
                            if (eot_r = '1') then
                                state_next  <= S_PROC_PT2;
                            else
                                state_next  <= S_PROC_PT;
                            end if;
                        else
                            count_next  <= count_r + 1;
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_PROC_PT2 =>
                if (bdo_ready = '1') then
                    end_of_block <= '1';
                    bdo_valid    <= '1';
                    state_next  <= S_PROC_DATPAD1;
                end if;

            when S_PROC_DATPAD1 =>
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        ca_set      <= '1';
                        sel_M		<= "011";
                        en_StateReg <= '1';
                        count_next  <= count_r + 1;
                        state_next      <= S_PROC_DATPAD0;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_PROC_DATPAD0 =>
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        sel_M		<= "100";
                        en_StateReg <= '1';
                        if (count_r <= PdivM-1) then
                            ca_set      <= '1';
                        elsif (count_r <= (PdivM_X2)-1) then
                            -- Noting
                        end if;
                        if (count_r = (PdivM_X2)-1) then
                            count_next  <= (others => '0');
                            first_block_next <= '1';
                            state_next       <= S_FINAL;
                        else
                            count_next  <= count_r + 1;
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_FINAL =>
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        ca_set      <= '1';
                        cb_set      <= '1';
                        is_final    <= '1';
                        --en_StateReg <= '1';--!
                        sel_M		<= "100";
                        --if (count_r <= FINAL_COUNT) then
                        if (count_r >= (FINAL_COUNT- PdivM)) then
                            if (decrypt_r = '1') then
                                if (bdi_valid = '1') then
                                    wait_next   <= '0';
                                    bdi_ready   <= '1';
                                    sel_bdi     <= '1';
                                    en_bdiReg   <= '1';
                                    L_bdiReg    <= '1';
                                    en_StateReg <= '1';
                                    count_next  <= count_r + 1;
                                    state_next  <= S_FINAL1_DEC;
                                    if (tag_match = '0') then
                                        auth_fail_next  <= '1';
                                    end if;
                                end if;
                            else
                                if (bdo_ready = '1') then
                                    wait_next   <= '0';
                                    en_bdoReg   <= '1';
                                    en_StateReg <= '1';
                                    count_next  <= count_r + 1;
                                    first_block_next <= '0';
                                    if (count_r = FINAL_COUNT) then --FINAL_COUNT-1
                                        end_of_block <= '1';
                                        state_next  <= S_RESET;
                                    end if;
                                    if (first_block_r = '0') and
                                        (count_r(2 downto 0) = "000") then
                                        bdo_valid   <= '1';
                                    end if;
                                end if;
                            end if;
                        else
                            wait_next   <= '0';
                            en_StateReg <= '1';
                            count_next  <= count_r + 1;
                        end if;
                        --end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_FINAL1_DEC =>
                if (rdi_valid = '1') then
                    rdi_ready   <= '1';
                    if (wait_r = '1') then
                        wait_next   <= '0';
                        ca_set      <= '1';
                        cb_set      <= '1';
                        is_final    <= '1';
                        sel_M		<= "100";
                        en_bdiReg   <= '1';
                        en_StateReg <= '1';
                        if (tag_match = '0') then
                            auth_fail_next  <= '1';
                        end if;
                        if (count_r = FINAL_COUNT-1) then
                            if (msg_auth_ready = '1')then
                                msg_auth_valid  <= '1';
                                if (tag_match = '0') or (auth_fail_r = '1') then
                                    msg_auth   <= '0';
                                else
                                    msg_auth   <= '1';
                                end if;
                                state_next  <= S_RESET;
                            else
                                state_next  <= S_WAIT_MSG_AUTH;
                            end if;
                        elsif (count_r(2 downto 0) = "111") then
                            state_next  <= S_FINAL;
                            count_next  <= count_r + 1;
                        else
                            count_next  <= count_r + 1;
                        end if;
                    else
                        wait_next   <= '1';
                    end if;
                end if;

            when S_WAIT_MSG_AUTH =>
                if (msg_auth_ready = '1')then
                    msg_auth_valid  <= '1';
                    if (auth_fail_r = '0') then
                        msg_auth   <= '1';
                    end if;
                    state_next  <= S_RESET;
                end if;

        end case;

    end process;

end behavioral;
