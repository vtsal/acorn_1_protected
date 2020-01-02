-------------------------------------------------------------------------------
--! @file       CipherCore.vhd
--! @author     Farnoud Farahmand
--! @brief      ACORN CipherCore
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use work.CAESAR_LWAPI_pkg.all;
use work.design_pkg.all;

entity CipherCore is
    -- generic (
        --! Reset behavior
        -- G_ASYNC_RSTN    : boolean := False; --! Async active low reset
        --! Block size (bits)
        -- G_DBLK_SIZE     : integer := 8;   --! Data
        -- G_KEY_SIZE      : integer := 128;   --! Key
        -- G_TAG_SIZE      : integer := 128;   --! Tag
        --! The number of bits required to hold block size expressed in
        --! bytes = log2_ceil(G_DBLK_SIZE/8)
        -- G_LBS_BYTES     : integer := 2
    -- );
    port (
        --! Global
        clk             : in  std_logic;
        rst             : in  std_logic;
        --! PreProcessor (data)
        key_a           : in  std_logic_vector(SW       -1 downto 0);
        key_b           : in  std_logic_vector(SW       -1 downto 0);
        bdi_a           : in  std_logic_vector(PW      -1 downto 0);
        bdi_b           : in  std_logic_vector(PW      -1 downto 0);
        --! PreProcessor (controls)
        key_ready       : out std_logic;
        key_valid       : in  std_logic;
        key_update      : in  std_logic;
        decrypt_in      : in  std_logic;
        bdi_ready       : out std_logic;
        bdi_valid       : in  std_logic;
        bdi_type        : in  std_logic_vector(4                -1 downto 0);
        bdi_partial     : in  std_logic;
        bdi_eot         : in  std_logic;
        bdi_eoi         : in  std_logic;
        bdi_size        : in  std_logic_vector(3    -1 downto 0);
        bdi_valid_bytes : in  std_logic_vector(PWdiv8    -1 downto 0);
        bdi_pad_loc     : in  std_logic_vector(PWdiv8    -1 downto 0);
        --! PostProcessor
        bdo_a           : out std_logic_vector(PW      -1 downto 0);
        bdo_b           : out std_logic_vector(PW      -1 downto 0);
        bdo_valid       : out std_logic;
        bdo_ready       : in  std_logic;
		-- All ones
		bdo_valid_bytes : out  STD_LOGIC_VECTOR (PWdiv8   -1 downto 0);
		-- Not connected
		bdo_type        : out  STD_LOGIC_VECTOR (4       -1 downto 0);
		end_of_block    : out  STD_LOGIC;
		decrypt_out     : out  STD_LOGIC;
        --bdo_size        : out std_logic_vector(G_LBS_BYTES+1    -1 downto 0);
        --done            : out std_logic;
        msg_auth        : out std_logic;
        msg_auth_valid  : out std_logic;
        msg_auth_ready  : in  std_logic;

        rdi_valid       : in  std_logic;
        rdi_ready       : out std_logic;
        rdi_data        : in STD_LOGIC_VECTOR (RW-1 downto 0)
    );
end entity CipherCore;

architecture structure of CipherCore is

-------------------------------------------------------------------
	    signal en_KeyReg1    :  std_logic;
        signal en_KeyReg2    :  std_logic;
	    signal L_KeyReg      :  std_logic;
        signal en_bdiReg     :  std_logic;
        signal L_bdiReg      :  std_logic;
        signal en_bdoReg     :  std_logic;
        signal rst_KeyReg    :  std_logic;
		signal en_StateReg   :  std_logic;
		signal rst_StateReg  :  std_logic;
		signal ca_set        :  std_logic;
		signal cb_set        :  std_logic;
        -- signal sel_LoadKey   :  std_logic;
        signal sel_bdi       :  std_logic;
   	    signal is_final      :  std_logic;
        signal sel_decrypt   :  std_logic;
		signal tag_match     :  std_logic;
		signal sel_M         :  std_logic_vector(2 downto 0);
-------------------------------------------------------------------

begin
    Datapath: entity work.ACORN_Datapath(dataflow)
    port map(
            clk                 => clk,
            rst                 => rst,
            key_a               => key_a,
            key_b               => key_b,
            bdi_a               => bdi_a,
            bdi_b               => bdi_b,
            bdo_a               => bdo_a,
            bdo_b               => bdo_b,
            en_KeyReg1          => en_KeyReg1,
            en_KeyReg2          => en_KeyReg2,
            L_KeyReg            => L_KeyReg,
            en_bdiReg           => en_bdiReg,
            L_bdiReg            => L_bdiReg,
            en_bdoReg           => en_bdoReg,
            rst_KeyReg          => rst_KeyReg,
            en_StateReg         => en_StateReg,
            rst_StateReg        => rst_StateReg,
            ca_set              => ca_set,
            cb_set              => cb_set,
            -- sel_LoadKey         => sel_LoadKey,
            sel_bdi             => sel_bdi,
            is_final            => is_final,
            sel_decrypt         => sel_decrypt,
            tag_match           => tag_match,
            sel_M               => sel_M,
            rand                => rdi_data
    );

	Controller: entity work.ACORN_Control(behavioral)
    port map(
            clk                 => clk,
            rst                 => rst,
            key_update          => key_update,
            key_valid           => key_valid,
            key_ready           => key_ready,
            bdi_valid           => bdi_valid,
            bdi_ready           => bdi_ready,
            decrypt             => decrypt_in,
            bdi_eot             => bdi_eot,
            bdi_eoi             => bdi_eoi,
            bdi_type            => bdi_type,
            bdo_ready           => bdo_ready,
            bdo_valid           => bdo_valid,
			bdo_valid_bytes		=> bdo_valid_bytes,
            bdo_type            => bdo_type,
            msg_auth_valid      => msg_auth_valid,
            msg_auth_ready      => msg_auth_ready,
            msg_auth            => msg_auth,
            en_KeyReg1          => en_KeyReg1,
            en_KeyReg2          => en_KeyReg2,
            L_KeyReg            => L_KeyReg,
            en_bdiReg           => en_bdiReg,
            L_bdiReg            => L_bdiReg,
            en_bdoReg           => en_bdoReg,
            rst_KeyReg			=> rst_KeyReg,
            en_StateReg         => en_StateReg,
            rst_StateReg        => rst_StateReg,
            ca_set              => ca_set,
            cb_set              => cb_set,
            -- sel_LoadKey         => sel_LoadKey,
            sel_bdi             => sel_bdi,
            is_final            => is_final,
            sel_decrypt         => sel_decrypt,
            tag_match           => tag_match,
            --done                => done,
            sel_M               => sel_M,
            end_of_block        => end_of_block,
            rdi_valid           => rdi_valid,
            rdi_ready           => rdi_ready
    );

end structure;
