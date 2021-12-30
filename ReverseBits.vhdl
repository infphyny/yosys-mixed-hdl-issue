library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ReverseBits is
    generic (N : integer := 1);
    port( 
        i_bits : in std_logic_vector(N-1 downto 0);
        o_bits : out std_logic_vector(N-1 downto 0)
     );
end ReverseBits;

architecture ReverseBitsArch of ReverseBits is

 begin
    
   process(i_bits)
   begin 
    for i in 0 to N-1 loop
    
        o_bits(i) <= i_bits(N-1 - i);
        
    end loop;
   
   end process;

 end ReverseBitsArch;   