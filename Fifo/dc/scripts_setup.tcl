set CLOCK_PORT  "din_clk"
set RST_PORT    "rstn"
set TIME_UNIT   1
set CYCLE200M   [expr 5 * $TIME_UNIT]


# set_driving_cell -lib_cell AN2D0BWP7T30P140 [all_inputs]
# set_drive 0 [get_ports[list $CLOCK_PORT]]
# set_load -pin_load 0.02 [all_outputs]
#set_fanout_load 4 [all_outputs]

create_clock -name $CLOCK_PORT -period $CYCLE200M [get_ports $CLOCK_PORT]
# set_clock_uncertainty -hold 0.053 [all_clocks]
# set_clock_transition 0.15 [all_clocks]
# set_input_transition 0.2 [remove_from_collection [all_inputs] [all_clocks]]
#set_input_delay 350 -clock $CLOCK_PORT [remove_from_collection [all_inputs] $CLOCK_PORT]
#set_output_delay 350 -clock $CLOCK_PORT [all_outputs]

#rst_ports
# set rst_inputs [get_ports [list $RST_PORT]]
# set_ideal_network $rst_inputs


echo "\nscripts_setup.tcl run to end...\n"

