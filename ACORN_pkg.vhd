-- =====================================================================
-- Copyright © 2016-2017 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;

package ACORN_pkg is

    constant STATE_SIZE 	:integer:= 293;
	constant M_SIZE     	:integer:= 1;
	constant PARAM_SIZE 	:integer:= 128;
    constant PdivM          :integer := PARAM_SIZE/M_SIZE;
    constant PdivM_X2       :integer := PdivM*2;
    constant INIT_COUNT     :integer := (1792/M_SIZE)-PdivM_X2-1;
    constant FINAL_COUNT    :integer := 768/M_SIZE;
    constant Mdiv8          :integer := M_SIZE/8;

--    function maj (x,y,z : std_logic) return std_logic;
--    function ch  (x,y,z : std_logic) return std_logic;
--    -- V3 functions
--    function KSG128 (S_12, S_154, S_235, S_61, S_193, S_230,
--                     S_111, S_66 : std_logic) return std_logic;
--    function FBK128 (S_0, S_107, S_244, S_23, S_160, S_196,
--                     ca, cb, ks : std_logic) return std_logic;
--
--    -- V1 functions
--    function KSG128_v2 (S_12, S_154, S_235, S_61, S_193 : std_logic) return std_logic;
--    function FBK128_v2 (S_0, S_107, S_244, S_23, S_160, S_196, S_230,
--                    S_111, S_66,
--                    ca, cb, ks : std_logic) return std_logic;

end ACORN_pkg;

--package body ACORN_pkg is
--
--    function maj (x,y,z : std_logic) return std_logic is
--        variable output : std_logic;
--        begin
--            output := (x and y) xor (x and z) xor (y and z);
--            return output;
--        end maj;
--
--    function ch (x,y,z : std_logic) return std_logic is
--        variable output : std_logic;
--        begin
--            output := (x and y) xor ((not x) and z);
--            return output;
--        end ch;
--
--    -- V3 functions
--    function KSG128 (S_12, S_154, S_235, S_61, S_193, S_230,
--                     S_111, S_66 : std_logic) return std_logic is
--        variable output : std_logic;
--        begin
--            output := S_12 xor S_154 xor maj(S_235,S_61,S_193) xor ch(S_230,S_111,S_66);
--            return output;
--            --return (S_12 xor S_154 xor maj(S_235,S_61,S_193) xor ch(S_230,S_111,S_66));
--        end KSG128;
--
--    function FBK128 (S_0, S_107, S_244, S_23, S_160, S_196,
--                     ca, cb, ks : std_logic) return std_logic is
--        variable output : std_logic;
--        begin
--            output := S_0 xor (not S_107) xor maj(S_244,S_23,S_160) xor
--            (ca and S_196) xor (cb and ks);
--            return output;
--            --return (S_0 xor (not S_107) xor maj(S_244,S_23,S_160) xor
--            --(ca and S_196) xor (cb and ks));
--        end FBK128;
--
--    -- V1 functions
--    function KSG128_v2 (S_12, S_154, S_235, S_61, S_193 : std_logic) return std_logic is
--        variable output : std_logic;
--        begin
--            output := S_12 xor S_154 xor maj(S_235,S_61,S_193);
--            return output;
--            --return (S_12 xor S_154 xor maj(S_235,S_61,S_193));
--        end KSG128_v2;
--
--    function FBK128_v2 (S_0, S_107, S_244, S_23, S_160, S_196, S_230,
--                     S_111, S_66,
--                     ca, cb, ks : std_logic) return std_logic is
--        variable output : std_logic;
--        begin
--            output := S_0 xor (not S_107) xor maj(S_244,S_23,S_160)
--            xor ch(S_230,S_111,S_66) xor (ca and S_196) xor (cb and ks);
--            return output;
--            --return (S_0 xor (not S_107) xor maj(S_244,S_23,S_160)
--            --xor ch(S_230,S_111,S_66) xor (ca and S_196) xor (cb and ks));
--        end FBK128_v2;
--
--end package body ACORN_pkg;
--
