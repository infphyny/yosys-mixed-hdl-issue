# Project setup
PROJ      := BarrelShifter

DEVICE    := 25k
PACKAGE   := CABGA256
SPEED     := 6
# IO
LPF       := io.lpf
# Top level module
TOP       := top
# Files
VHDL_FILES :=  BarrelShifter.vhdl Mux.vhdl ReverseBits.vhdl top.vhdl
VERILOG_FILES := pll.v 


TARGET_FREQUENCY := 50
#PLL

PLL_ICLK := clock_25
CLKIN := 25

CLKOUT0_NAME := clockout0
CLKOUT_0 := 50

CLKOUT1_NAME := clockout1
CLKOUT1 := 50
PHASE1 := 90 


PLL_MODULE_NAME := ECP5PLL
PLL_FILENAME := pll.v


# Yosys cookbook https://github.com/Ravenslofty/yosys-cookbook
# Generate for speed
#yosys -p "synth_ecp5 -abc9 -json filename.json"

#Generate for reduce area 
#yosys -p "synth_ecp5 -abc9 -nowidelut -json filename.json"

#Generate for more efficient mapping
#yosys -p "scratchpad -copy abc9.script.flow3 abc9.script; synth_ecp5 -abc9 -json filename.json"


#.PHONY: $(PROJ) clean ipll ipll2 write-flash write-sram

		

$(PROJ).bit $(PROJ).svf : $(PROJ).config
	ecppack $(PROJ).config $(PROJ).bit
	ecppack $(PROJ).config --svf $(PROJ).svf

$(PROJ).config : $(PROJ).json
	nextpnr-ecp5  -r --$(DEVICE)  --json $< --textcfg $@ --package $(PACKAGE) --speed $(SPEED) --freq $(TARGET_FREQUENCY) --lpf-allow-unconstrained
	#--lpf $(LPF) 


$(PROJ).json : $(FILES)
# Success with read_verilog command 
#	yosys -m  ghdl -p "ghdl  --std=08 $(VHDL_FILES) -e $(TOP) ; read_verilog $(VERILOG_FILES); synth_ecp5 -abc9  -top $(TOP) -json $(PROJ).json" 
# Error without read_verilog command
	yosys -m  ghdl -p "ghdl  --std=08 $(VHDL_FILES) -e $(TOP) ; synth_ecp5 -abc9  -top $(TOP) -json $(PROJ).json" $(VERILOG_FILES)
#	yosys -p " synth_ecp5 -abc9 -top $(TOP) -json $(PROJ).json" $(VERILOG_FILES)
#$(FILES)



.PHONY: $(PROJ) clean ipll ipll2 write-flash write-sram  conv_vhdl


conv_vhdl:
#	ghdl --synth --out=verilog  Mux.vhdl -e Mux > Mux.v
#	ghdl --synth --out=verilog  ReverseBits.vhdl -e ReverseBits > ReverseBits.v
#	ghdl --synth --out=verilog  BarrelShifter.vhdl -e BarrelShifter > BarrelShifter.v
#	ghdl --synth --out=verilog  Mux.vhdl  ReverseBits.vhdl BarrelShifter.vhdl top.vhdl -e top > top.v
	yosys -m ghdl -p 'ghdl --std=08 $(VHDL_FILES) -e top ; write_verilog top.v'

ipll:
	ecppll --reset  --module $(PLL_MODULE_NAME)  --clkin_name $(PLL_ICLK)  --clkin $(CLKIN) --clkout0_name $(CLKOUT0_NAME) --clkout0 $(CLKOUT_0) --internal_feedback  -f $(PLL_FILENAME) 

# clkout0 and clkout1 defined
ipll2:
	ecppll --reset  --module $(PLL_MODULE_NAME)  --clkin_name $(PLL_ICLK)  --clkin $(CLKIN) --clkout0_name $(CLKOUT0_NAME) --clkout0 $(CLKOUT_0) --clkout1_name $(CLKOUT1_NAME) --clkout1 $(CLKOUT1) --phase1 $(PHASE1) --internal_feedback  -f $(PLL_FILENAME) 
write-flash:
	openFPGALoader --write-flash --bitstream $(PROJ).bit

write-sram:
	openFPGALoader --write-sram --bitstream $(PROJ).bit


clean:
	rm -f *.svf *.bit *.json *.config *.v 

