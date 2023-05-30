onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+top_design  -L xlconstant_v1_1_7 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.top_design xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {top_design.udo}

run 1000ns

endsim

quit -force
