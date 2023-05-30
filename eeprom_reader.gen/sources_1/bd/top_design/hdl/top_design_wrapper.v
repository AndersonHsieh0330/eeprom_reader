//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Tue May 30 01:14:25 2023
//Host        : DESKTOP-695FRHT running 64-bit major release  (build 9200)
//Command     : generate_target top_design_wrapper.bd
//Design      : top_design_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module top_design_wrapper
   (BTN,
    CK_IO28,
    CK_IO29,
    CK_IO_0_TO_7,
    CK_IO_26_TO_27,
    LED,
    LED0_B,
    LED0_G,
    LED0_R,
    SW,
    SYS_CLK);
  input [3:0]BTN;
  output CK_IO28;
  inout CK_IO29;
  output [7:0]CK_IO_0_TO_7;
  output [1:0]CK_IO_26_TO_27;
  output [3:0]LED;
  output LED0_B;
  output LED0_G;
  output LED0_R;
  input [3:0]SW;
  input SYS_CLK;

  wire [3:0]BTN;
  wire CK_IO28;
  wire CK_IO29;
  wire [7:0]CK_IO_0_TO_7;
  wire [1:0]CK_IO_26_TO_27;
  wire [3:0]LED;
  wire LED0_B;
  wire LED0_G;
  wire LED0_R;
  wire [3:0]SW;
  wire SYS_CLK;

  top_design top_design_i
       (.BTN(BTN),
        .CK_IO28(CK_IO28),
        .CK_IO29(CK_IO29),
        .CK_IO_0_TO_7(CK_IO_0_TO_7),
        .CK_IO_26_TO_27(CK_IO_26_TO_27),
        .LED(LED),
        .LED0_B(LED0_B),
        .LED0_G(LED0_G),
        .LED0_R(LED0_R),
        .SW(SW),
        .SYS_CLK(SYS_CLK));
endmodule
