-- and_3TI

library ieee;
use ieee.std_logic_1164.ALL;

entity and_3TI is
    port (

	xa, xb, ya, yb  : in  std_logic;
	m : in std_logic_vector(2 downto 0);
	o1, o2 		: out std_logic
	);

end entity and_3TI;

architecture structural of and_3TI is

signal x1, x2, x3, y1, y2, y3, z1, z2, z3 : std_logic;

attribute keep : string;
attribute keep of x1, x2, x3, y1, y2, y3, z1, z2, z3 : signal is "true";

begin

x1 <= xa xor m(2); -- resharing
x2 <= xb;
x3 <= m(2);

y1 <= ya; -- resharing
y2 <= yb xor m(1);
y3 <= m(1);

anda: entity work.and_3TI_a(dataflow)

	port map(
	xa => x2,
	xb => x3,
	ya => y2,
	yb => y3,
	m => m(0),
	o  => z1

	);

andb: entity work.and_3TI_b(dataflow)

	port map(
	xa => x3,
	xb => x1,
	ya => y3,
	yb => y1,
	m => m(0),
	o  => z2

	);

andc: entity work.and_3TI_c(dataflow)

	port map(
	xa => x1,
	xb => x2,
	ya => y1,
	yb => y2,
	m => m(0),
	o  => z3

	);

o1 <= z1 xor z2;
o2 <= z3;

end structural;
