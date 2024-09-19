#------------------------------------------------------------------------------------------
# dc_setup.tcl
# Use of Design Compiler
# Author       : ZhuTao
# Last modified: 2023/03/20

#------------------------------------------------------------------------------------------
set DESIGN_NAME "fifo_s2b"
set verilog_files [list\
../rtl/fifo_s2b.v\
../rtl/ccnt.v\
../rtl/fifo.v\
../rtl/ramdp.v\
]

#------------------------------------------------------------------------------------------
set REPORTS_DIR "report"
set RESULTS_DIR "results"
file mkdir ${REPORTS_DIR}
file mkdir ${RESULTS_DIR}

#------------------------------------------------------------------------------------------
# Logical Library Settings
set_app_var search_path "$search_path $ADDITIONAL_SEARCH_PATH"
set_app_var target_library "$TARGET_LIBRARY_FILES $dw_foundation_path"
set_app_var link_library "* $target_library"
# set_app_var symbol_library $SYMBOL_LIBRARY_FILES

#------------------------------------------------------------------------------------------
# Read design
file mkdir ./work
define_design_lib WORK -path ./work
analyze -format verilog {$verilog_files}
elaborate ${DESIGN_NAME}
ungroup -all -flatten

#------------------------------------------------------------------------------------------
#scripts for design
source ./scripts_setup.tcl

#------------------------------------------------------------------------------------------
# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs [all_designs]
check_design -summary
check_design > ${REPORTS_DIR}/check_design.rpt

#------------------------------------------------------------------------------------------
# Compile the design
compile_ultra 
# compile_ultra -no_autoungroup -incremental
change_names -rules verilog -hierarchy

#------------------------------------------------------------------------------------------
# Generate final reports
report_qor > ${REPORTS_DIR}/qor.rpt
report_timing -transition_time -nets -attributes -nosplit > ${REPORTS_DIR}/timing.rpt
report_area -nosplit > ${REPORTS_DIR}/area.rpt
report_power -nosplit > ${REPORTS_DIR}/power.rpt
report_clock_gating -nosplit > ${REPORTS_DIR}/cg.rpt
report_reference -nosplit > ${REPORTS_DIR}/ref.rpt

#------------------------------------------------------------------------------------------
# Save the design
set FINAL_VERILOG_OUTPUT_FILE "${DESIGN_NAME}.mapped.v"
set FINAL_SDC_OUTPUT_FILE     "${DESIGN_NAME}.mapped.sdc"
write -format verilog -hierarchy -output ${RESULTS_DIR}/${FINAL_VERILOG_OUTPUT_FILE}
write_sdc -nosplit ${RESULTS_DIR}/${FINAL_SDC_OUTPUT_FILE}


echo "\ndc_setup.tcl run to end...\n"

