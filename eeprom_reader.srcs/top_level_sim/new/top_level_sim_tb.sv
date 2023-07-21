`timescale 1ns / 1ps

module top_level_sim();
logic SYS_CLK;
logic reset;
logic start;
logic SDA;
logic SCL;
logic [3:0] LED;
logic [2:0] RBG_LED; // RGB => [2:0] respectively
logic [7:0] DATA_OUT;

initial begin
end

top eeprom_interface_inst(
    SYS_CLK(SYS_CLK), 
    BTN({2'b0, start, reset}),     
    SW(1'b1),      
    SDA(SDA),
    SCL_OUT(SCL),
    LED(LED),     
    LED0_R(RBG_LED[2]),  
    LED0_G(RBG_LED[1]),
    LED0_B(RBG_LED[0]),  
    DATA_OUT(DATA_OUT)
)
endmodule
