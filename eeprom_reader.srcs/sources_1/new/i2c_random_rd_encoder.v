`timescale 1ns / 1ps

`include "constants.vh"

/*
    this module is intended to use the "Random Read" feature of 24 series eeprom 
    to read one signle byte at a 15 bit address

    And this module does not have a reset input, once "start" signal is signaled
    state machine propogates and all inputs are ignored until STOP bit is sent to eeprom
*/
module i2c_random_rd_encoder (
    input             reset, // reset is required to reset values in all registers
    input             data_adr_en,
    input      [14:0] data_adr,
    input             device_adr_en,
    input      [ 2:0] device_adr,
    input             start,
    input             double_speed_scl,   // double the speed of SCL_IN
    input             SCL_IN,
    inout             SDA,
    output            SCL_OUT, // goes to eeprom
    output reg        done
);
  reg         reset_q;
  reg         done_q;
  reg         start_delay_q;
  wire        read_SDA_en;
  reg         SDA_out_q; // SDA should be pulled HIGH in idle
  reg  [ 2:0] state;
  reg  [ 3:0] data_bit_count;

  // registers to save start address and device address, load on reset
  reg  [14:0] data_adr_q;
  wire [7:0] data_adr_high_out;
  wire [7:0] data_adr_low_out;
  reg  [ 2:0] device_adr_q;
  wire [ 7:0] ctrl_byte;
  reg         r_w;  // read(1) or write(0) for control byte, initial value = 0 because we need a dummy write before reading
  reg         ack_recv_delay;  // this bit indicates if acknowledge bit was received
  reg  [ 7:0] data_out_q;  // register the received data and only outputs when all 8 bits are received
  reg         start_q; // when this bit is one, the state machine is currently propogating. It is then switched to 0 once STOP bit is sent to eeprom
  reg         receiving_data_byte; // this bit is one on the cycle after the the acknowledge bit from READ control byte

  // microchip datasheet says first 4 bits has to be 1010, this is inverse for indexing
  assign ctrl_byte = {r_w, device_adr_q, 4'b0101};
  assign SDA = read_SDA_en ? 1'bz : SDA_out_q;
  
  // 24C256 series eeprom supports 256k = 262144 bits of data, which is 32768 bytes
  // and it's byte addressible for there are 15 bits of data needed, one extra bit is concenated with a 0
  assign data_adr_high_out = {data_adr_q[6:0], 1'b0};
  assign data_adr_low_out = data_adr_q[14:7];
  assign read_SDA_en = receiving_data_byte ? ~(data_bit_count == 8) : data_bit_count == 8;

  // this is eqivalent of sampling reset at posedge SCL_IN
  always @(posedge double_speed_scl) begin
    if (~SCL_IN) begin
      reset_q <= 1;
    end else if (reset_q) begin
      reset_q <= 0;
    end
  end

  always @(posedge SCL_IN) begin
    if (start) begin
      done_q <= 0;
    end
  end
  // sample start signal at posedge SCL_IN
  always @(posedge SCL_IN) begin
    if (done) begin
     start_delay_q <= 1;

      // inverse data start address for indexing
      // inverse device_address for indexing
      device_adr_q[0] <= device_adr[2];
      device_adr_q[1] <= device_adr[1];
      device_adr_q[2] <= device_adr[0];

      data_adr_q[0]  <= data_adr[14];
      data_adr_q[1]  <= data_adr[13];
      data_adr_q[2]  <= data_adr[12];
      data_adr_q[3]  <= data_adr[11];
      data_adr_q[4]  <= data_adr[10];
      data_adr_q[5]  <= data_adr[9];
      data_adr_q[6]  <= data_adr[8];
      data_adr_q[7]  <= data_adr[7];
      data_adr_q[8]  <= data_adr[6];
      data_adr_q[9]  <= data_adr[5];
      data_adr_q[10] <= data_adr[4];
      data_adr_q[11] <= data_adr[3];
      data_adr_q[12] <= data_adr[2];
      data_adr_q[13] <= data_adr[1];
      data_adr_q[14] <= data_adr[0];
      end
  end
  /*
    used to update start signal, sample at falling edge of SCL_IN so start_q can be used as mux select signal for SCL_OUT
    because scl line should be pulled high during idle state, when we switch over to SCL_IN we want it to start low
  */
  assign SCL_OUT = start_delay_q ? SCL_IN : 1'b1; 

  always @(negedge SCL_IN) begin
    if (reset_q) begin
      start_q <= 0;
      data_adr_q <= 0;
      device_adr_q <= 0;
    end
  end
  
  always @(negedge double_speed_scl) begin
    if (reset_q) begin
      SDA_out_q <= 0;
      data_bit_count <= 0;
      state <= `IDLE;
      done <= 1;
      r_w <= 0; // start with write 
      ack_recv_delay <= 0;
      data_out_q <= 0;
      receiving_data_byte <= 0;      
      
    end else begin
    case (state)
        `IDLE: begin
            if (start_q && SCL_OUT) begin
              SDA_out_q <= 0; // START bit
              r_w <= 0;
              data_bit_count <= 0;
              state <= `SEND_DEVICE_ADR;
            end
        end
        `SEND_DEVICE_ADR: begin
          if (!SCL_OUT) begin
            if (read_SDA_en & ~SDA) begin
              // acknowledge received
              ack_recv_delay <= 1;
              data_bit_count <= 0;
              receiving_data_byte <= r_w; // if we sent a read control byte, that means we're about to start reading data byte
              state <= r_w ? `READ_DATA_BYTE : `SEND_WORD_ADR_HIGH;
            end else begin
              SDA_out_q <= ctrl_byte[data_bit_count];
              data_bit_count <= data_bit_count + 1;
            end
          end  
        end
        `SEND_WORD_ADR_HIGH: begin
          if (!SCL_OUT) begin
            if (ack_recv_delay) begin
              ack_recv_delay <= 0;
              SDA_out_q <= data_adr_high_out[data_bit_count]; // once ack bit is reset we need to start sending first bit right away
              data_bit_count <= data_bit_count + 1;
            end else if (read_SDA_en & ~SDA) begin
              ack_recv_delay <= 1;
              data_bit_count <= 0;
              state <= `SEND_WORD_ADR_LOW;
            end else begin
              SDA_out_q <= data_adr_high_out[data_bit_count];
              data_bit_count <= data_bit_count + 1;
            end
          end
        end
        `SEND_WORD_ADR_LOW: begin
          if (!SCL_OUT) begin
            if (ack_recv_delay) begin
              ack_recv_delay <= 0;
              // once we switch acknowledge related flags off we need to output first bit right away
              SDA_out_q <= data_adr_low_out[data_bit_count];
              data_bit_count <= data_bit_count + 1;
            end else if (read_SDA_en & ~SDA) begin
              ack_recv_delay <= 1;
              state <= `IDLE; // go to IDEL state to send START bit
              r_w <= 1;  // read
              data_bit_count <= 0;
            end else begin
              SDA_out_q <= data_adr_low_out[data_bit_count];
              data_bit_count <= data_bit_count + 1;
            end 
          end
        end
        `READ_DATA_BYTE: begin
          if (!SCL_OUT) begin
            if (ack_recv_delay) begin                        
              ack_recv_delay <= 0;                           
              data_out_q[data_bit_count] <= SDA;
              data_bit_count <= data_bit_count + 1;
            end else begin
              data_out_q[data_bit_count] <= SDA;
              data_bit_count <= data_bit_count + 1;
              SDA_out_q <= data_bit_count == 7; // no acknowledge
              if (data_bit_count == 7) begin
                SDA_out_q <= 1; // no acknowledge
                state <= `SEND_STOP_BIT;
              end
            end
          end
        end
        `SEND_STOP_BIT: begin
          if (SCL_OUT) begin
            SDA_out_q <= 0; // STOP BIT
            state <= `IDLE;
            start_q <= 0;
          end
        end
    endcase
  end
    end

endmodule
