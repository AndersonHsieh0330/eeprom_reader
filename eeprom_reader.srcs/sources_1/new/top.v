`timescale 1ns / 1ps
`include "constants.vh"

module top (
    input            SYS_CLK,  // from on board oscillator to FPGA chip, 200kHz
    input      [3:0] BTN,      // BTN[0] is reset, BTN[1] is next data
    input      [3:0] SW,       // SW[0] = LOW, sequential read from address 00 ; SW[0] = HIGH,
    inout            SDA,
    output reg       SCL,
    output     [3:0] LED,      // LED[0] to indicate reset signal, LED[1] for next data
    output           LED0_R,   // for future rror signal
    output           LED0_G,
    output           LED0_B,   // sequential read from
    output     [7:0] DATA_OUT  // 8 bit data at every address in eeprom

);
  wire reset = BTN[0];
  wire next_data = BTN[1];
  wire sequential_read_mode = SW[0];
  assign LED    = BTN;  //  mapp all buttons to leds
  assign LED0_G = sequential_read_mode;
  assign LED0_B = !sequential_read_mode;

  always @(posedge SYS_CLK) begin
    SCL <= ~SCL;
  end

  i2c_sql_rd_encoder sql_encoder_inst (
    .reset(BTN[0]),
    .data_start_adr_en(BTN[0]),
    .data_start_adr(0'b0000000_00000),
    .device_adr_en(BTN[0]),
    .device_adr(BTN[2:0]),
    .next_data(BTN[0]),
    .double_speed_scl(SYS_CLK),
    .SCL(SCL),
    .SDA(SDA),
    .data_out(DATA_OUT)
  );
endmodule
