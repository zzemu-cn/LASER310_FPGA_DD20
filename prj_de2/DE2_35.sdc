## Generated SDC file "DE2_35.out.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Full Version"

## DATE    "Wed Nov 28 18:36:13 2018"

##
## DEVICE  "EP2C35F672C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {sys_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLK50MHZ}]
create_clock -name {clk_27} -period 37.037 [get_ports {CLK27MHZ}]
#create_clock -name "clk_27" -period 37.000 [get_ports {CLK27MHZ}]

create_clock -name {dly_clk} -period 1000 [get_ports {DLY_CLK}]

create_clock -name {vga_clk} -period 40.000 -waveform { 0.000 20.000 } [get_ports {VGA_CLK}]
create_clock -name {tik_clk} -period 100.000 -waveform { 0.000 50.000 } [get_registers {CLK10MHZ}]
#create_clock -name {emu_cass_clk} -period 560.000 -waveform { 0.000 280.000 } [get_registers {EMU_CASS_CLK}]

create_clock -name {cpu_clk} -period 100	-waveform { 0 20 } [get_nets {CPU_CLK}]

create_clock -name {kb_clk} -period 640 -waveform { 0 320 } [get_nets {KB_CLK}]

create_clock -name {clk_aud} -period 53.879 [get_ports {AUD_CTRL_CLK}]

set_clock_groups -asynchronous -group {sys_clk} -group {cpu_clk} -group {clk_27} -group {dly_clk} -group {vga_clk} -group {kb_clk}  -group {clk_aud}
#set_clock_groups -asynchronous -group {sys_clk} -group {cpu_clk} -group {clk_27} -group {vga_clk}  -group {clk_aud}

# Automatically constrain PLL and other generated clocks
#derive_pll_clocks -create_base_clocks

#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {VGA_AUDIO_PLL|altpll_component|pll|clk[0]} -source [get_pins {VGA_AUDIO_PLL|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 14 -divide_by 15 -master_clock {clk_27} [get_pins {VGA_AUDIO_PLL|altpll_component|pll|clk[0]}] 



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

