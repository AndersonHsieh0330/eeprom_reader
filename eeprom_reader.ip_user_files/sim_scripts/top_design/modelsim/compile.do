vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xlconstant_v1_1_7

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xlconstant_v1_1_7 modelsim_lib/msim/xlconstant_v1_1_7

vlog -work xil_defaultlib  -incr -mfcu  \
"../../../bd/top_design/ip/top_design_top_0_0/sim/top_design_top_0_0.v" \

vlog -work xlconstant_v1_1_7  -incr -mfcu  \
"../../../../eeprom_reader.gen/sources_1/bd/top_design/ipshared/badb/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  \
"../../../bd/top_design/ip/top_design_xlconstant_0_2/sim/top_design_xlconstant_0_2.v" \
"../../../bd/top_design/sim/top_design.v" \

vlog -work xil_defaultlib \
"glbl.v"

