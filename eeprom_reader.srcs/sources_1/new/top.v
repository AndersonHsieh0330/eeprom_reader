`timescale 1ns / 1ps

module top(
    input CLK, 
    input [1:0] BTN, // BTN[0] is reset, BTN[1] is next data
    output SCL,
    output [3:0] LED
    );
    
    assign LED[0] = BTN; // for testing
    assign SCL = CLK;
    
    
endmodule

module i2c_encoder(
    input reset,
    input address
);
endmodule
