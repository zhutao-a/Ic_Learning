set ROOT_DIR "/mnt/hgfs/linux/fifo"

set dw_foundation_path "/home/synopsys/syn/O-2018.06-SP1/libraries/syn/dw_foundation.sldb"
#logical libraries,logical design and script files
set ADDITIONAL_SEARCH_PATH  "${ROOT_DIR}/rtl   ${ROOT_DIR}/dc";
#Logical technology file
set TARGET_LIBRARY_FILES    "/home/ic_libs/TSMC.90/aci/sc-x/synopsys/slow.db";    
#Symbol library file
set SYMBOL_LIBRARY_FILES    "/home/ic_libs/TSMC.90/aci/sc-x/symbols/synopsys/tsmc090.sdb";

echo "\ncommon_setup.tcl run to end...\n"


