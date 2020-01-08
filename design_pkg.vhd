------------------------------------------------------------------------------
--! @File        : design_pkg.vhd (Design package for Lightweight)
--! @Brief       : CAESAR lightweight API package
--!   ______   ________  _______    ______
--!  /      \ /        |/       \  /      \
--! /$$$$$$  |$$$$$$$$/ $$$$$$$  |/$$$$$$  |
--! $$ |  $$/ $$ |__    $$ |__$$ |$$ | _$$/
--! $$ |      $$    |   $$    $$< $$ |/    |
--! $$ |   __ $$$$$/    $$$$$$$  |$$ |$$$$ |
--! $$ \__/  |$$ |_____ $$ |  $$ |$$ \__$$ |
--! $$    $$/ $$       |$$ |  $$ |$$    $$/
--!  $$$$$$/  $$$$$$$$/ $$/   $$/  $$$$$$/
--!
--! @Author     : Panasayya Yalla & Ekawat (ice) Homsirikamol
--! @Copyright  : Copyright © 2016 Cryptographic Engineering Research Group
--!                ECE Department, George Mason University Fairfax, VA, U.S.A.
--!                All rights Reserved.
--! @license    This project is released under the GNU Public License.
--!             The license and distribution terms for this file may be
--!             found in the file LICENSE in this distribution or at
--!             http://www.gnu.org/licenses/gpl-3.0.txt
--! @note       This is publicly available encryption source code that falls
--!             under the License Exception TSU (Technology and software-
--!             —unrestricted)
--------------------------------------------------------------------------------
--! Description
--!
--!
--!
--!
--!
--!
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;


package design_pkg is

    --! I/O parameters
    constant PW             : integer := 8;
    constant SW             : integer := 8;
    --constant RW             : integer := 15;
    constant RW             : integer := 64; -- Added by Behnaz
    constant PWdiv8         : integer := PW/8;
    constant SWdiv8         : integer := SW/8;
    constant LSBYTES        : integer := PW/8+1;---log2(w/8);



    --! Design parameters
    constant G_DBLK_SIZE     : integer := 128;   --! Data
    constant G_KEY_SIZE      : integer := 128;   --! Key
    constant G_TAG_SIZE      : integer := 128;   --! Tag

    --! TAG VERIFICAITON SETTING
    ----False --> Performed externally in the preprocessor. hence need to
    ---            pass into cipher core
    ----True  --> Performed internally with in the ciphercore
    constant TAG_INTERNAL  : boolean := True;
    --! Async active low reset
    ----TRUE   --> NOT YET SUPPORTED!!!
    ----FALSE  --> Active-high synchronous reset
    constant ASYNC_RSTN    : boolean := False;

end design_pkg;
