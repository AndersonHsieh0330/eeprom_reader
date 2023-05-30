onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc "  -L xlconstant_v1_1_7 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.top_design xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {top_design.udo}

run 1000ns

quit -force
