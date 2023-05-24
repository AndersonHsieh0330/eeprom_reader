-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/top_design/ip/top_design_top_0_0/sim/top_design_top_0_0.v" \
-endlib
-makelib xcelium_lib/xlconstant_v1_1_7 \
  "../../../../eeprom_reader.gen/sources_1/bd/top_design/ipshared/badb/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/top_design/ip/top_design_xlconstant_0_2/sim/top_design_xlconstant_0_2.v" \
  "../../../bd/top_design/sim/top_design.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

