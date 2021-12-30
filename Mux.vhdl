library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

entity Mux is
generic (N : integer := 1);
  port(
      i_source : in std_logic_vector(N-1 downto 0);
      i_sel    : in std_logic_vector( integer(ceil(log2(real(N))))-1 downto 0);
      o_val    : out std_logic
  );

end Mux;


architecture MuxArch of Mux is

begin

    process(i_source,i_sel)
    
    begin
        o_val <= i_source(to_integer(unsigned(i_sel)));
    end process;



end MuxArch;    