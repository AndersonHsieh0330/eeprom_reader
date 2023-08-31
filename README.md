## eeprom_reader

This project sythesize a eeprom interface reader for 24 series I2C eeprom on a Arty-S7 board, using a Xilinx Spartan 7 FPGA. Especially targting 24 series I2C EEPROM with 256K bits storage. Ex. 24LC256, FT24C256

for XX24C256 series EEPROMS:
each page is 64 bytes
32K * 8 means there are 32768 addresses and each address stores 8 bits, so total there is 256k = 262144 bits
address are 15 bits. The verilog models of this project targets 15 bit addresses.

![pic](https://github.com/AndersonHsieh0330/eeprom_reader/blob/master/info/full_setup.jpg?raw=true)

### How to use
There are 4 push buttons on the Arty-S7 board, and this project uses 3 user input buttons as follows 
- BTN[0] = reset
- BTN[1] = start/next 
- BTN[2] = scl_reset

Once the device is starting up0 user should press the scl_reset button first. Once scl_reset is released press the reset button to reset all the internal signals and registers. Once that's done user can then press the start button, the device will read from address 0x0000, by pressing the start button again the device will read from next address which is address 0x0001.

Once the address read reaches the last address, which is 0x7FFF for 256k bit eeprom, the next address will loop back to 0x0000.

### Implementation
Based on the datasheet specifications, this project implements a **state machine** to deliver the correct signals to the SDA line. <br>2 clock signals are generated, 200khz for system clk and 100khz for the SCL clock that the EEPROM receives.
The 8 bit data ouputs are mapped to 8 GPIO pins on the board, please check [the contraint file](https://github.com/AndersonHsieh0330/eeprom_reader/blob/master/eeprom_reader.srcs/constrs_1/new/primary.xdc) for more details

### Simulation
Go into Vivado and run simulation set named "random read" and or "top_level_sim" to see simulation waveforms. The i2c_random_rd_encoder_tb testbench in simulation set "random read" tests the encoder directly, where top_evel_sim_tb in simulation set "top_level_sim" tests the top module with input button signals

Heres the waveform after running the "random read" simulation set behavior simualtion
![pic](https://github.com/AndersonHsieh0330/eeprom_reader/blob/master/info/random_read%20simulation%20result.png?raw=true)

### Timing 
Please use the following timing diagram to understand the internals of the verilog encoder
![pic](https://github.com/AndersonHsieh0330/eeprom_reader/blob/master/info/wavedrom%20timing.png?raw=true)

### Future
1. Debug with logic analyzer
2. Integrate into [my 8 bit softcore CPU project](https://github.com/AndersonHsieh0330/softcore_cpu) for loading written program in EEPROM
