`timescale 1ns / 1ps

module top(
    input CLK, 
    output [3:0] LED,
    input BTN // this is BTN0 on the board 
    );
    assign LED[0] = BTN;
endmodule

