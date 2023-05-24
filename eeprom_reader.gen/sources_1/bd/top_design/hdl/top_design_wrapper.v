//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Wed May 24 01:37:18 2023
//Host        : DESKTOP-695FRHT running 64-bit major release  (build 9200)
//Command     : generate_target top_design_wrapper.bd
//Design      : top_design_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module top_design_wrapper
   (BTN_0,
    CLK,
    LED,
    dout);
  input BTN_0;
  input CLK;
  output [3:0]LED;
  output [1:0]dout;

  wire BTN_0;
  wire CLK;
  wire [3:0]LED;
  wire [1:0]dout;

  top_design top_design_i
       (.BTN_0(BTN_0),
        .CLK(CLK),
        .LED(LED),
        .dout(dout));
endmodule
