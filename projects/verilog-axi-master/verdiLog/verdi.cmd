debImport "-sv" "./common/function.v" "-f" "rtl/filelist.f"
nsMsgSwitchTab -tab cmpl
nsMsgSwitchTab -tab general
srcHBSelect "axil_adapter.axil_adapter_rd_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "axil_adapter.axil_adapter_rd_inst" -delim "."
srcHBSelect "axil_adapter.axil_adapter_rd_inst" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 75 -pos 6 -win $_nTrace1
srcAction -pos 75 6 3 -win $_nTrace1 -name "clog2" -ctrlKey off
srcHBSelect "\$root" -win $_nTrace1
srcHBSelect "axil_adapter" -win $_nTrace1
srcSetScope -win $_nTrace1 "axil_adapter" -delim "."
srcHBSelect "axil_adapter" -win $_nTrace1
srcHBSelect "axil_adapter.axil_adapter_rd_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "axil_adapter.axil_adapter_rd_inst" -delim "."
srcHBSelect "axil_adapter.axil_adapter_rd_inst" -win $_nTrace1
srcHBSelect "axil_adapter.axil_adapter_wr_inst" -win $_nTrace1
srcSetScope -win $_nTrace1 "axil_adapter.axil_adapter_wr_inst" -delim "."
srcHBSelect "axil_adapter.axil_adapter_wr_inst" -win $_nTrace1
debExit
