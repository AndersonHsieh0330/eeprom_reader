`include "constants.vh"

// sql = sequential
// this is essentially one random read at address 0x
module i2c_sql_rd_encoder(
    input reset,
    input data_address,
    input [2:0] device_address,
    input next_data,
    input SCL,
    inout SDA,
    output [7:0] data_out);
    
    reg waiting_for_ack = 0;
    reg [1:0] state;
    reg clock_cycle_count;
    // start bit + 1010 + device address[2:0] + address_high[6:0] + address_low[7:0]
    reg ctrl_n_address = {1,1010,000,00000000,00000000};
    
    always@(posedge SCL) begin
        if (reset) begin
            state             <= `IDLE;
            clock_cycle_count <= 0;
            SDA               <= 1;
            end else begin
            
        end
    end
    
    always@(negedge SCL) begin
        case(state)
            `IDLE: begin
                SDA   <= 0; // start bit
                state <= `SEND_CTL_BYTE;
            end
            `SEND_CTL_BYTE: begin
                
            end
        endcase
        endmodule
        
