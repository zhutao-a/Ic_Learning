.PHONY :build

build:
	vcs \
		-full64 \
		-timescale=1ns/1ps \
		-debug_access+all \
		+no_notifier \
		-cm line+tgl \
		-l vcs.log \
		-f ./rtl/filelist.f \
		./testbench.v \
		-top testbench

sim:
	./simv \
		-ucli -do dump.tcl \
		-cm line+tgl \
		-l run.log \
		-top testbench

cov:
	dve -full64 -covdir simv.vdb &

verdi_lib:
	@mkdir -p log
	@mkdir -p ~/.verdi_setting
	vericom \
		-2001 \
		-sv \
		-rcFile ~/.verdi_setting/novas.rc \
		-f ./rtl/filelist.f \
		./testbench.v

verdi:
	@mkdir -p log
	verdi \
	-nologo \
	-rcFile ~/.verdi_setting/novas.rc \
	-guiConf ~/.verdi_setting/novas.conf \
	-logdir ./log \
	-top testbench &
