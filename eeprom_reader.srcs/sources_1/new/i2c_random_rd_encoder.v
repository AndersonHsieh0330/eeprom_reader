`timescale 1ns / 1ps

`include "constants.vh"

/*
    this module is intended to use the "Random Read" feature of 24 series eeprom 
    to read one signle byte at a 15 bit address
*/
module i2c_random_rd_encoder (
    input             reset, // reset is required to reset values in all registers
    input      [14:0] data_adr,
    input      [ 2:0] device_adr,
    input             start,
    input             double_speed_scl,   // double the speed of SCL_IN
    input             SCL_IN,
    inout             SDA,
    output            SCL_OUT, // goes to eeprom
    output reg  [7:0] data_out,
    output            done
);
  reg         done_q;
  reg         reset_q;
  reg         SDA_out_q; // SDA should be pulled HIGH in idle
  reg  [2:0]  state;
  reg  [3:0]  data_bit_count;
  reg  [7:0]  clk_cycle_counter;

  // registers to save start address and device address, load on reset
  reg  [14:0] data_adr_q;
  wire [7:0]  data_adr_high_out;
  wire [7:0]  data_adr_low_out;
  reg  [2:0]  device_adr_q;
  wire [7:0]  ctrl_byte;
  reg         r_w;  // read(1) or write(0) for control byte, initial value = 0 because we need a dummy write before reading
  reg         ack_recv_delay;  // this bit indicates if acknowledge bit was received
  reg  [7:0]  data_out_q;  // register the received data and only outputs when all 8 bits are received
  reg         data_out_en;
  reg         receiving_data_byte; // this bit is one on the cycle after the the acknowledge bit from READ control byte
  wire        read_SDA_en;
  reg         data_out_en_delay;
  reg         done_q_delay;

  // microchip datasheet says first 4 bits has to be 1010, this is inverse for indexing
  assign ctrl_byte = {r_w, device_adr_q, 4'b0101};
  assign SDA = read_SDA_en ? 1'bz : SDA_out_q;
  assign read_SDA_en = receiving_data_byte ? ~(data_bit_count == 9) : data_bit_count == 9;

  // 24C256 series eeprom supports 256k = 262144 bits of data, which is 32768 bytes
  // and it's byte addressible for there are 15 bits of data needed, one extra bit is concenated with a 0
  assign data_adr_high_out = {data_adr_q[6:0], 1'b0};
  assign data_adr_low_out = data_adr_q[14:7];
  assign SCL_OUT = ~done_q ? SCL_IN : 1'b1; 
  assign done = done_q_delay;

  // reset_q is used to reset all the signals in state machine always block
  always @(posedge double_speed_scl) begin
    if (reset) begin
      reset_q <= 1;
    end else begin
      reset_q <= 0;
    end
  end
  
  always @(posedge done_q) begin
    if (reset) begin
      data_out <= 0;
    end else begin
      data_out <= data_out_q;
    end
  end

  always @(posedge SCL_IN) begin
    if (reset) begin
      data_out_en_delay <= 0;
    end else if (data_out_en_delay) begin
      data_out_en_delay <= 0;
    end else if (data_out_en) begin
      data_out_en_delay <= 1;
    end
  end

  always @(posedge SCL_IN) begin
    if (reset) begin
      done_q_delay <= 1;
    end else if (done_q & start) begin
      done_q_delay <= 0;
    end else if (~done_q_delay) begin
      done_q_delay <= done_q;
    end
  end

  always @(double_speed_scl) begin
    if (reset | clk_cycle_counter == 190) begin
      clk_cycle_counter <= 0;
    end else if (done_q & start) begin
      clk_cycle_counter <= 1;
    end else if (~done_q) begin
        clk_cycle_counter = clk_cycle_counter + 1;
      end
  end

  always @(posedge SCL_IN) begin
    if (reset) begin
      done_q <= 1;
    end else if (start & done_q) begin
      done_q <= 0;
    end else if (data_out_en_delay) begin
      done_q <= 1;
    end
  end

  always @(posedge SCL_IN) begin
    if (done_q & start) begin
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
  
  always @(negedge double_speed_scl) begin
    if (reset_q) begin
      SDA_out_q <= 1;
      data_bit_count <= 0;
      state <= `IDLE;
      r_w <= 0; // start with write 
      ack_recv_delay <= 0;
      data_out_q <= 0;
      receiving_data_byte <= 0;      
      data_out_en <= 0;
    end else begin
    case (state)
        `IDLE: begin
          SDA_out_q <= 1;
          data_bit_count <= 0;
          receiving_data_byte <= 0;
          if (~done_q && SCL_OUT) begin
            SDA_out_q <= 0; // START bit
            state <= `SEND_DEVICE_ADR;
          end
        end
        `SEND_DEVICE_ADR: begin
          if (!SCL_OUT) begin
              SDA_out_q <= ctrl_byte[data_bit_count];
              data_bit_count <= data_bit_count + 1;
          end else begin
            if (read_SDA_en & ~SDA) begin
              state <= r_w ? `READ_DATA_BYTE : `SEND_WORD_ADR_HIGH;
            end
          end  
        end
        `SEND_WORD_ADR_HIGH: begin
          if (!SCL_OUT) begin
              SDA_out_q <= data_adr_high_out[data_bit_count==9?0:data_bit_count];
              data_bit_count <= data_bit_count == 9 ? 1 : data_bit_count + 1;
          end else begin
            if (read_SDA_en & ~SDA) begin
              state <= `SEND_WORD_ADR_LOW;
            end
          end
        end
        `SEND_WORD_ADR_LOW: begin
          if (!SCL_OUT) begin
              SDA_out_q <= data_adr_low_out[data_bit_count==9?0:data_bit_count];
              data_bit_count <= data_bit_count == 9 ? 1 : data_bit_count + 1;
            end else begin
              if (read_SDA_en & ~SDA) begin
              state <= `IDLE; // go to IDEL state to send START bit
              r_w <= 1;  // read
            end
          end
        end
        `READ_DATA_BYTE: begin
          if (!SCL_OUT) begin
              if (data_bit_count == 8) begin
                SDA_out_q <= 1; // no acknowledge
                data_bit_count <= data_bit_count + 1;
                data_out_en <= 1;
              end else if (data_out_en) begin
                SDA_out_q <= 0;
                state <= `SEND_STOP_BIT;
                data_out_en <= 0;
              end else begin
                data_out_q[data_bit_count==9?0:data_bit_count] <= SDA;
                data_bit_count <= data_bit_count == 9 ? 1 : data_bit_count + 1;
                receiving_data_byte <= 1;
              end
          end 
        end
        `SEND_STOP_BIT: begin
          SDA_out_q <= 0;
          if (SCL_OUT) begin
            SDA_out_q <= 1; // STOP BIT
            state <= `IDLE;
          end
        end
    endcase
  end
    end

endmodule
