`include "constants.vh"

/*
    this module is intended to use the "Random Read" feature of 24 series eeprom 
    to read one signle byte at a 15 bit address

    And this module does not have a reset input, once "start" signal is signaled
    state machine propogates and all inputs are ignored until STOP bit is sent to eeprom
*/
module i2c_random_rd_encoder (
    input             data_adr_en,
    input      [14:0] data_adr,
    input             device_adr_en,
    input      [ 2:0] device_adr,
    input             start,
    input             double_speed_scl,   // double the speed of SCL_IN
    input             SCL_IN,
    inout             SDA,
    output            SCL_OUT // goes to eeprom
);

  reg         read_SDA_en = 0;
  reg         SDA_out_q = 1; // SDA should be pulled HIGH in idle
  reg  [ 2:0] state = `IDLE;

  reg  [ 4:0] data_bit_count = 0;

  // registers to save start address and device address, load on reset
  reg  [14:0] data_adr_q;
  wire [15:0] data_adr_out;
  reg  [ 2:0] device_adr_q;
  wire [ 7:0] ctrl_byte;
  reg         r_w = 0;  // read(1) or write(0) for control byte, initial value = 0 because we need a dummy write before reading
  reg         ack_recv_delay = 0;  // this bit indicates if acknowledge bit was received
  reg  [ 7:0] data_out_q = 0;  // register the received data and only outputs when all 8 bits are received
  reg         start_q = 0; // when this bit is one, the state machine is currently propogating. It is then switched to 0 once STOP bit is sent to eeprom

  // microchip datasheet says first 4 bits has to be 1010, this is inverse for indexing
  assign ctrl_byte = {r_w, device_adr_q, 4'b0101};
  assign SDA = read_SDA_en ? 1'bz : SDA_out_q;
  
  // 24C256 series eeprom supports 256k = 262144 bits of data, which is 32768 bytes
  // and it's byte addressible for there are 15 bits of data needed, one extra bit is concenated with a 0
  assign data_adr_out = {data_adr_q, 1'b0};
  assign SCL_OUT = state == start_q ? 1'b1 : SCL_IN; 

  // inverse data start address for indexing
  always @(posedge SCL_IN) begin
    if (data_adr_en) begin
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

  // inverse device_address for indexing
  always @(posedge SCL_IN) begin
    if (device_adr_en) begin
      //inverse bits
      device_adr_q[0] <= device_adr[2];
      device_adr_q[1] <= device_adr[1];
      device_adr_q[2] <= device_adr[0];
    end
  end

  /*
    used to update start signal, sample at every rising edge of system clk  
    START bit will be sent at the next negative edge of double speed clk(system clk) AND SCL is high
  */
  always @(posedge double_speed_scl) begin
    start_q <= start;
  end
  
  always @(negedge double_speed_scl) begin
    case (state)
        `IDLE: begin
            if (start_q && SCL) begin
                read_SDA_en <= 0;
                SDA_out_q <= 0 // START bit
                
            end
        end
        `SEND_DEVICE_ADR: begin
          if (read_SDA_en) begin
            if (~SDA) begin
              // acknowledge received
              ack_recv_delay <= 1;
              state <= r_w ? `READ_DATA_BYTE : `SEND_WORD_ADR_HIGH;
            end
          end else if (!SCL_IN) begin
            SDA_out_q <= ctrl_byte[data_bit_count];
            data_bit_count <= data_bit_count == 4'b1000 ? 0 : data_bit_count + 1;
            read_SDA_en <= data_bit_count == 4'b1000;
          end
        end  
    endcase

    end

  always @(negedge double_speed_scl) begin
    case(state)
        `IDLE: begin
            if (start_q && SCL) begin
                state <= `SEND_DEVICE_ADR
            end
        end
        `SEND_DEVICE_ADR: begin
        end
    endcase
endmodule
