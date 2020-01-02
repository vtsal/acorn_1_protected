LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shiftn IS
    GENERIC( 
        D_WIDTH : INTEGER := 16;
        S_WIDTH : INTEGER := 64                
    ) ;
    PORT (
        d    : IN STD_LOGIC_VECTOR(D_WIDTH-1 DOWNTO 0);
        enable : IN STD_LOGIC;
        load : IN STD_LOGIC;
        sin  : IN STD_LOGIC_VECTOR(S_WIDTH-1 downto 0);
        clk  : IN STD_LOGIC;
        rst  : IN STD_LOGIC;
        q    : OUT STD_LOGIC_VECTOR(D_WIDTH-1 DOWNTO 0)
    );
END shiftn;

ARCHITECTURE behavioral OF shiftn IS
    SIGNAL Qt: STD_LOGIC_VECTOR(D_WIDTH-1 DOWNTO 0);
    
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                Qt  <= (others => '0');
            ELSIF enable = '1' THEN
                IF load = '1' THEN
                    Qt <= d;
                ELSE
                    Qt <= sin(S_WIDTH-1 downto 0) & Qt(D_WIDTH-1 downto S_WIDTH);
                END IF;
            END IF;
        END IF;
    END PROCESS;
    q <= Qt;
    
END behavioral; 