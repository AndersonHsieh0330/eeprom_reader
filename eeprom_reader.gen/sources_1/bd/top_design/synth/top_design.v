//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Tue May 30 01:14:25 2023
//Host        : DESKTOP-695FRHT running 64-bit major release  (build 9200)
//Command     : generate_target top_design.bd
//Design      : top_design
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "top_design,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=top_design,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "top_design.hwdef" *) 
module top_design
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SYS_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SYS_CLK, CLK_DOMAIN top_design_CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input SYS_CLK;

  wire [3:0]BTN_0_1;
  wire CLK_0_1;
  wire Net;
  wire [3:0]SW_0_1;
  wire [3:0]top_0_LED;
  wire [7:0]top_DATA_OUT;
  wire top_LED0_B;
  wire top_LED0_G;
  wire top_LED0_R;
  wire top_SCL;
  wire [1:0]xlconstant_0_dout;

  assign BTN_0_1 = BTN[3:0];
  assign CK_IO28 = top_SCL;
  assign CK_IO_0_TO_7[7:0] = top_DATA_OUT;
  assign CK_IO_26_TO_27[1:0] = xlconstant_0_dout;
  assign CLK_0_1 = SYS_CLK;
  assign LED[3:0] = top_0_LED;
  assign LED0_B = top_LED0_B;
  assign LED0_G = top_LED0_G;
  assign LED0_R = top_LED0_R;
  assign SW_0_1 = SW[3:0];
  top_design_top_0_0 top
       (.BTN(BTN_0_1),
        .DATA_OUT(top_DATA_OUT),
        .LED(top_0_LED),
        .LED0_B(top_LED0_B),
        .LED0_G(top_LED0_G),
        .LED0_R(top_LED0_R),
        .SCL(top_SCL),
        .SDA(CK_IO29),
        .SW(SW_0_1),
        .SYS_CLK(CLK_0_1));
  top_design_xlconstant_0_2 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule
