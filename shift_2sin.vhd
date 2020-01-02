LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shift_2sin IS
    GENERIC(
        D_WIDTH  : INTEGER  := 64;
        S1_WIDTH : INTEGER := 16;
        S2_WIDTH : INTEGER := 1
    ) ;
    PORT (
        d    : IN STD_LOGIC_VECTOR(D_WIDTH-1 DOWNTO 0);
        en_s1  : IN STD_LOGIC;
        en_s2  : IN STD_LOGIC;
        load : IN STD_LOGIC;
        sin1 : IN STD_LOGIC_VECTOR(S1_WIDTH-1 downto 0);
        sin2 : IN STD_LOGIC_VECTOR(S2_WIDTH-1 downto 0);
        clk  : IN STD_LOGIC;
        rst  : IN STD_LOGIC;
        q    : OUT STD_LOGIC_VECTOR(D_WIDTH-1 DOWNTO 0)
    );
END shift_2sin;

ARCHITECTURE behavioral OF shift_2sin IS
    SIGNAL Qt: STD_LOGIC_VECTOR(D_WIDTH-1 DOWNTO 0);

BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                Qt  <= (others => '0');
            ELSIF en_s1 = '1' THEN
                IF load = '1' THEN
                    Qt <= d;
                ELSE
                    Qt <= sin1(S1_WIDTH-1 downto 0) & Qt(D_WIDTH-1 downto S1_WIDTH);
                END IF;
            ELSIF en_s2 = '1' THEN
                IF load = '1' THEN
                    Qt <= d;
                ELSE
                    Qt <= sin2(S2_WIDTH-1 downto 0) & Qt(D_WIDTH-1 downto S2_WIDTH);
                END IF;
            END IF;
        END IF;
    END PROCESS;
    q <= Qt;

END behavioral;
