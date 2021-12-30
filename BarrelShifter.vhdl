-- 
--
--
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
entity BarrelShifter is --shift logical left --shift logical right  --shift arithmetic right 
   port(
       i_op     : in std_logic_vector(1 downto 0);  
       i_source : in std_logic_vector(31 downto 0);
       i_shamt  : in std_logic_vector(4 downto 0);  --shift amount
       o_result : out std_logic_vector(31 downto 0)
   );

 end BarrelShifter;  


 architecture BarrelShifterArch of BarrelShifter is

    type MuxInputs is array (0 to 31) of std_logic_vector(1 downto 0);
    type StageMuxInputs is array (0 to 4) of MuxInputs;
    type StageMuxOutput is array (0 to 3) of std_logic_vector(31 downto 0);

    signal shift_val : std_logic;   
  
    signal stages_inputs : StageMuxInputs;
    signal stages_outputs : StageMuxOutput;

    signal inputs : std_logic_vector(31 downto 0);
    signal outputs : std_logic_vector(31 downto 0); 
    signal reverse_inputs : std_logic_vector(31 downto 0);
    signal reverse_outputs : std_logic_vector(31 downto 0);

    signal stage_1_inputs : MuxInputs;
    signal stage_2_inputs : MuxInputs;
    signal stage_3_inputs : MuxInputs;
    signal stage_4_inputs : MuxInputs;
    signal stage_5_inputs : MuxInputs;
   -- signal s : std_logic;
    signal stage_1_output : std_logic_vector(31 downto 0);
    signal stage_2_output : std_logic_vector(31 downto 0);
    signal stage_3_output : std_logic_vector(31 downto 0);
    signal stage_4_output : std_logic_vector(31 downto 0);
    --signal stage_2_output : std_logic_vector(31 downto 0);
    
    
    
    component Mux
    generic (N : integer);
    port(
        i_source : in std_logic_vector(N-1 downto 0);
        i_sel    : in std_logic_vector( integer(ceil(log2(real(N))))-1 downto 0);
        o_val    : out std_logic
    );
    end component;
      
    component ReverseBits
    generic (N : integer);
    port( 
        i_bits : in std_logic_vector(N-1 downto 0);
        o_bits : out std_logic_vector(N-1 downto 0)
     );
    end component;


  begin


  reverse_input_bits  : ReverseBits generic map(N => 32)
  port map(
      i_bits => i_source,
      o_bits => reverse_inputs
  ) ;
  

   reverse_output_bits : ReverseBits generic map(N=>32)
     port map(
         i_bits => outputs,
         o_bits => reverse_outputs
     );


   mux_gen : for i in 0 to 31 generate
     
   
    bit0_gen : if i = 0 generate
    stage_1_inputs(i)(1) <= shift_val;
    stage_1_inputs(i)(0) <= inputs(i); 
      mux0 : Mux   generic map(N => 2)
      port map(
          i_source => stage_1_inputs(i),
          i_sel(0) => i_shamt(0),
          o_val => stage_1_output(i)
          );
     end generate bit0_gen; 

    bitx_gen : if i > 0 generate
    stage_1_inputs(i)(1) <= inputs(i-1);
    stage_1_inputs(i)(0) <= inputs(i); 
     mux_n : Mux  generic map(N => 2)
     port map(
         i_source => stage_1_inputs(i),
         i_sel(0) => i_shamt(0),
         o_val => stage_1_output(i)
         );
    end generate bitx_gen;

   end generate mux_gen;



   mux_gen_stage_2 : for i in 0 to 31  generate

   mux1_stage_2 : if i < 2 generate
   stage_2_inputs(i)(1) <= shift_val;
   stage_2_inputs(i)(0) <= stage_1_output(i);
   mux1 : Mux   generic map(N => 2)
   port map(
       i_source => stage_2_inputs(i),
       i_sel(0) => i_shamt(1),
       o_val => stage_2_output(i)
       );
  
   end generate mux1_stage_2; 
    
   muxn_stage_2 : if i>= 2 generate
   
   stage_2_inputs(i)(1) <= stage_1_output(i-2); 
   stage_2_inputs(i)(0) <= stage_1_output(i); 
   mux_stage_2 : Mux   generic map(N => 2)
   port map(
       i_source => stage_2_inputs(i),
       i_sel(0) => i_shamt(1),
       o_val => stage_2_output(i)
       );
   end generate muxn_stage_2;



   end generate mux_gen_stage_2;


   mux_gen_stage_3 : for i in 0 to 31  generate

   mux1_stage_3 : if i < 4 generate
   stage_3_inputs(i)(1) <= shift_val;
   stage_3_inputs(i)(0) <= stage_2_output(i);
   mux_stage_3 : Mux   generic map(N => 2)
   port map(
       i_source => stage_3_inputs(i),
       i_sel(0) => i_shamt(2),
       o_val => stage_3_output(i)
       );
  
   end generate mux1_stage_3; 
    
   muxn_stage_3 : if i>= 4 generate
   
   stage_3_inputs(i)(1) <= stage_2_output(i-4); 
   stage_3_inputs(i)(0) <= stage_2_output(i); 
   mux_stage_2 : Mux   generic map(N => 2)
   port map(
       i_source => stage_3_inputs(i),
       i_sel(0) => i_shamt(2),
       o_val => stage_3_output(i)
       );
   end generate muxn_stage_3;



   end generate mux_gen_stage_3;

   mux_gen_stage_4 : for i in 0 to 31  generate

   mux1_stage_4 : if i < 8 generate
   stage_4_inputs(i)(1) <= shift_val;
   stage_4_inputs(i)(0) <= stage_3_output(i);
   mux_stage_4 : Mux   generic map(N => 2)
   port map(
       i_source => stage_4_inputs(i),
       i_sel(0) => i_shamt(3),
       o_val => stage_4_output(i)
       );
  
   end generate mux1_stage_4; 
    
   muxn_stage_4 : if i>= 8 generate
   
   stage_4_inputs(i)(1) <= stage_3_output(i-8); 
   stage_4_inputs(i)(0) <= stage_3_output(i); 
   mux_stage_4 : Mux   generic map(N => 2)
   port map(
       i_source => stage_4_inputs(i),
       i_sel(0) => i_shamt(3),
       o_val =>  stage_4_output(i)
       );
   end generate muxn_stage_4;



   end generate mux_gen_stage_4;

   mux_gen_stage_5 : for i in 0 to 31  generate

   mux1_stage_5 : if i < 16 generate
   stage_5_inputs(i)(1) <= shift_val;
   stage_5_inputs(i)(0) <= stage_4_output(i);
   mux_stage_5 : Mux   generic map(N => 2)
   port map(
       i_source => stage_5_inputs(i),
       i_sel(0) => i_shamt(4),
       o_val => outputs(i)
       );
  
   end generate mux1_stage_5; 
    
   muxn_stage_5 : if i>= 16 generate
   
   stage_5_inputs(i)(1) <= stage_4_output(i-16); 
   stage_5_inputs(i)(0) <= stage_4_output(i); 
   mux_stage_5 : Mux   generic map(N => 2)
   port map(
       i_source => stage_5_inputs(i),
       i_sel(0) => i_shamt(4),
       o_val => outputs(i)
       );
   end generate muxn_stage_5;



   end generate mux_gen_stage_5;


   process(i_op,i_source,i_shamt,outputs,reverse_inputs,reverse_outputs)
   begin
    
    case i_op is

        when "00" => --shift logical left
        shift_val <= '0'; 
        inputs <= i_source; 
        o_result <= outputs;    
        when "01" => -- shift logical right
        shift_val <= '0';  
        inputs <= reverse_inputs; 
        --inputs(0 to 31) <= i_source(31 downto 0); 
        o_result <= reverse_outputs;
        when "10" => -- shift arithmetic right
        inputs <= reverse_inputs;
        shift_val <= i_source(31);
        o_result <= reverse_outputs;
        when others =>
        o_result <= outputs;
        inputs <= i_source;
        shift_val <= '0';
    end case;    

   end process; 

--    build_stages : for j in 0 to 4 generate
   
--    stage_0 : if j = 0 generate
    
--    mux_gen : for i in 0 to 31 generate
     
--    bit0_gen : if i = j generate
--    stage_inputs(j)(i)(1) <= '0';
--    stage_inputs(j)(i)(0) <= i_source(i); 
--      mux0 : Mux   generic map(N => 2)
--      port map(
--          i_source => stage_inputs(j)(i),
--          i_sel(0) => i_shamt(j),
--          o_val => stage_1_output(j)(i)
--          );
--     end generate bit0_gen; 

--    bitx_gen : if i > j generate
--    stage_inputs(j)(i)(1) <= i_source(i-1);
--    stage_inputs(j)(i)(0) <= i_source(i); 
--     mux_n : Mux  generic map(N => 2)
--     port map(
--         i_source => stage_inputs(j)(i),
--         i_sel(0) => i_shamt(j),
--         o_val => stage_output(j)(i)
--         );
--    end generate bitx_gen;

--   end generate mux_gen;
    
--    end generate stage_0;

--    stage_1_to_3 : if j > 0 and j < 4 generate

--    mux_gen_stage : for i in 0 to 31 generate
    
--    end generate mux_gen_stage; 

--    end generate stage_1_to_3;


--    end generate build_stages;



   -- process(i_op,i_source,i_shamt)

   --  o_result <= x"00000000";
     
   -- begin

  --  end process    

    

 end BarrelShifterArch;   