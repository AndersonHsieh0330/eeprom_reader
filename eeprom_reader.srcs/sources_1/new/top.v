`timescale 1ns / 1ps
`include "constants.vh"

/*
  To use this module, scl_reset must be asserted before any signal
  since reset and start signals are sampled based on SCL
*/
module top (
    input            SYS_CLK,  // from on board oscillator to FPGA chip, 200kHz
    input      [3:0] BTN,      // BTN[0] = reset, BTN[1] = start, BTN[2] = scl_reset
    input      [3:0] SW,       // SW[0] = HIGH, random read; SW[0] = LOW, sequential read
    inout            SDA,
    output           SCL_OUT,
    output     [3:0] LED,      // LED[0] to indicate reset signal, LED[1] for start signal 
    output           LED0_R,   // for future error signal
    output           LED0_G,
    output           LED0_B,   // sequential read from
    output     [7:0] DATA_OUT  // 8 bit data at every address in eeprom

);
  wire done;
  wire reset;
  wire start;
  wire random_read_mode;
  wire scl_reset; 
  reg  SCL_IN;

  assign LED[2:0] = BTN[2:0]; 
  assign LED[3] = done; 
  assign LED0_G = random_read_mode;
  assign LED0_B = !random_read_mode;
  assign reset = BTN[0];
  assign start = BTN[1];
  assign scl_reset = BTN[2];
  assign random_read_mode = SW[0];
  
  always @(posedge SYS_CLK) begin
    if (scl_reset) begin
      SCL_IN <= 0; // must start at 0 so posedge of SCL lines up with posedge of SYS_CLK
    end else begin
      SCL_IN <= ~SCL_IN;
    end
  end

  i2c_random_rd_encoder random_encoder_inst (
    .reset(reset),
    .data_adr(0'b1000000_00000001),
    .device_adr(0'b101),
    .start(start),
    .double_speed_scl(SYS_CLK),
    .SCL_IN(SCL_IN),
    .SDA(SDA),
    .SCL_OUT(SCL_OUT),
    .data_out(DATA_OUT),
    .done(done)
  );
endmodule
