//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Wed May 24 01:37:18 2023
//Host        : DESKTOP-695FRHT running 64-bit major release  (build 9200)
//Command     : generate_target top_design.bd
//Design      : top_design
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "top_design,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=top_design,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "top_design.hwdef" *) 
module top_design
   (BTN_0,
    CLK,
    LED,
    dout);
  input BTN_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN top_design_CLK_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input CLK;
  output [3:0]LED;
  output [1:0]dout;

  wire BTN_0_1;
  wire CLK_0_1;
  wire [3:0]top_0_LED;
  wire [1:0]xlconstant_0_dout;

  assign BTN_0_1 = BTN_0;
  assign CLK_0_1 = CLK;
  assign LED[3:0] = top_0_LED;
  assign dout[1:0] = xlconstant_0_dout;
  top_design_top_0_0 top
       (.BTN(BTN_0_1),
        .CLK(CLK_0_1),
        .LED(top_0_LED));
  top_design_xlconstant_0_2 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule
