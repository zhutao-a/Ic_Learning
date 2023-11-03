#------------------------------------------------------------------------------------------
# Makefile
# Use of VCS+Verdi
# Author:    ZhuTao
# Last modified: 2023/03/20

#-------------------------------------------------------------------------------------------------------
#parameters
output_name=simv
CM=-cm line+cond+fsm+branch+tgl
CM_NAME=-cm_name ${output_name}
CM_DIR=-cm_dir ./${output_name}.vdb

#-------------------------------------------------------------------------------------------------------
#generate filelist
list:
	find ../rtl/ -name "*.v" > 		filelist
	find ../tb/  -name "*.v" >> 	filelist

#-------------------------------------------------------------------------------------------------------
#vcs compile
vcs:
	vcs -f filelist\
 		-l ${output_name}.log\
 		-o ${output_name}\
        -timescale=1ns/1ns\
        -full64  -R  +vc  +v2k  -sverilog  -debug_access+all\
        |tee vcs.log  

#-------------------------------------------------------------------------------------------------------
#dve to see waveform
dve:
	./${output_name} -gui &

#-------------------------------------------------------------------------------------------------------
#vcs to see code coverage
vcs_cov:
	vcs -f filelist\
 		-l ${output_name}.log\
 		-o ${output_name}\
 	  	${CM}\
 	  	${CM_NAME}\
 	  	${CM_DIR}\
        -timescale=1ns/1ns\
        -full64  -R  +vc  +v2k  -sverilog  -debug_access+all\
        |tee vcs.log
cov:
	dve -full64 -covdir ${output_name}.vdb &

#-------------------------------------------------------------------------------------------------------
#verdi to see waveform
verdi  :
	verdi -sv -f filelist -ssf tb.fsdb &

#-------------------------------------------------------------------------------------------------------
#clean
clean  :
	 rm  -rf  *~  core  csrc  ${output_name}*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd









