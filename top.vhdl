library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is

    port(
     i_clock : in std_logic;
     i_reset : in std_logic;
     i_op     :in std_logic_vector(1 downto 0);
     i_source : in std_logic_vector(31 downto 0);
     i_shamt : in std_logic_vector(4 downto 0);
     o_result : out std_logic_vector(31 downto 0)
    );

end top;    

architecture top_arch of top is
signal result : std_logic_vector(31 downto 0);    
signal clock_50,locked : std_logic;    
component ECP5PLL
  port( 
      reset : in std_logic;
      clock_25 : in std_logic;
      clockout0 :out std_logic;
      locked : out std_logic
      );
end component;
--attribute blackbox of ECP5PLL: component is true;
--attribute black_box of ecppll: component is true;

component BarrelShifter
port(
         i_op     : in std_logic_vector(1 downto 0);
         i_source : in std_logic_vector(31 downto 0);
         i_shamt  : in std_logic_vector(4 downto 0);  --shift amount
         o_result : out std_logic_vector(31 downto 0)
     );
end component;


begin

pll0 : ECP5PLL port map (reset => i_reset,clock_25 => i_clock, clockout0 => clock_50, locked => locked );
BarrelShifter0 : BarrelShifter port map(i_op =>i_op,i_source => i_source,i_shamt => i_shamt, o_result => result);


process(clock_50,locked)

 begin
    
  if locked = '0' then
  o_result <= x"00000000";
  elsif rising_edge(clock_50) then
    o_result <= result;    
end if; 

end process;

end top_arch;



