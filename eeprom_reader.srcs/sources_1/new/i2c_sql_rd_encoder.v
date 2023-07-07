`include "constants.vh"

// sql = sequential
// this is essentially one random read at address 0x
module i2c_sql_rd_encoder (
    input             reset,
    input             data_start_adr_en,
    input      [14:0] data_start_adr,
    input             device_adr_en,
    input      [ 2:0] device_adr,
    input             next_data,
    input             double_speed_scl,   // double the speed of SCL
    input             SCL,
    inout             SDA,
    output reg [ 7:0] data_out
);

  reg         read_SDA_en;
  reg         SDA_out_q;
  reg  [ 2:0] state;

  // we usually send 8 bits than wait for acknowledge signal from slave, thus 4 bits
  reg  [ 4:0] data_bit_count;

  // registers to save start address and device address, load on reset
  reg  [14:0] data_start_adr_q;
  wire [15:0] data_start_adr_out;
  reg  [ 2:0] device_adr_q;
  wire [ 7:0] ctrl_byte;
  reg         r_w;  // read(1) or write(0) for control byte
  reg         ack_recv_delay;  // this bit indicates if acknowledge bit was received
  reg  [ 7:0] data_out_q;  // register the received data and only outputs when all 8 bits are received
  reg         next_data_q;

  // last bit is R/W, 0 for Read
  // microchip datasheet says first 4 bits has to be 1010, this is inverse for indexing
  assign ctrl_byte = {r_w, device_adr_q, 4'b0101};

  assign SDA = read_SDA_en ? 1'bz : SDA_out_q;

  assign data_start_adr_out = {data_start_adr_q, 1'b0};

  always @(posedge SCL) begin
    if (data_start_adr_en) begin
      data_start_adr_q[0]  <= data_start_adr[14];
      data_start_adr_q[1]  <= data_start_adr[13];
      data_start_adr_q[2]  <= data_start_adr[12];
      data_start_adr_q[3]  <= data_start_adr[11];
      data_start_adr_q[4]  <= data_start_adr[10];
      data_start_adr_q[5]  <= data_start_adr[9];
      data_start_adr_q[6]  <= data_start_adr[8];
      data_start_adr_q[7]  <= data_start_adr[7];
      data_start_adr_q[8]  <= data_start_adr[6];
      data_start_adr_q[9]  <= data_start_adr[5];
      data_start_adr_q[10] <= data_start_adr[4];
      data_start_adr_q[11] <= data_start_adr[3];
      data_start_adr_q[12] <= data_start_adr[2];
      data_start_adr_q[13] <= data_start_adr[1];
      data_start_adr_q[14] <= data_start_adr[0];
    end
  end

  always @(posedge SCL) begin
    if (device_adr_en) begin
      //inverse bits
      device_adr_q[0] <= device_adr[2];
      device_adr_q[1] <= device_adr[1];
      device_adr_q[2] <= device_adr[0];
    end
  end

  always @(negedge double_speed_scl) begin
    if (reset) begin
      SDA_out_q      <= 1;
      read_SDA_en    <= 0;
      state          <= `IDLE;
      data_bit_count <= 0;
      ack_recv_delay <= 0;
      r_w            <= 0;
    end else begin
      case (state)
        `IDLE: begin
          SDA_out_q      <= 1;
          state          <= `IDLE;
          data_bit_count <= 0;
          if (ack_recv_delay) begin
            read_SDA_en <= 0;
            ack_recv_delay <= 0;
          end else if (SCL) begin
            // only send start bit when CLK is HIGH
            SDA_out_q <= 0;  // start bit
            state <= `SEND_CTL_BYTE;
          end
        end
        `SEND_CTL_BYTE: begin
          if (read_SDA_en) begin
            if (~SDA) begin
              // acknowledge received
              ack_recv_delay <= 1;
              state <= r_w ? `READ_DATA_BYTE : `SEND_ADR_HIGH;
            end
          end else if (!SCL) begin
            SDA_out_q <= ctrl_byte[data_bit_count];
            data_bit_count <= data_bit_count == 4'b1000 ? 0 : data_bit_count + 1;
            read_SDA_en <= data_bit_count == 4'b1000;
          end
        end
        `SEND_ADR_HIGH: begin
          if (ack_recv_delay) begin
            read_SDA_en <= 0;
            ack_recv_delay <= 0;
            // once we switch acknowledge related flags off we need to output first bit right away
            SDA_out_q <= data_start_adr_out[data_bit_count];
            data_bit_count <= data_bit_count + 1;
          end else if (read_SDA_en) begin
            if (~SDA) begin
              ack_recv_delay <= 1;
              state <= `SEND_ADR_LOW;
            end
          end else if (!SCL) begin
            SDA_out_q <= data_start_adr_out[data_bit_count];
            data_bit_count <= data_bit_count == 4'b1000 ? data_bit_count : data_bit_count + 1;
            read_SDA_en <= data_bit_count == 4'b1000;
          end
        end
        `SEND_ADR_LOW: begin
          if (ack_recv_delay) begin
            read_SDA_en <= 0;
            ack_recv_delay <= 0;
            // once we switch acknowledge related flags off we need to output first bit right away
            SDA_out_q <= data_start_adr_out[data_bit_count];
            data_bit_count <= data_bit_count + 1;
          end else if (read_SDA_en) begin
            if (~SDA) begin
              ack_recv_delay <= 1;
              state <= `IDLE;
              r_w <= 1;  // read
            end
          end else if (!SCL) begin
            SDA_out_q <= data_start_adr_out[data_bit_count];
            data_bit_count <= data_bit_count == 5'b10000 ? 0 : data_bit_count + 1;
            read_SDA_en <= data_bit_count == 5'b10000;
          end
        end
        `READ_DATA_BYTE: begin
          if (ack_recv_delay) begin
            read_SDA_en <= 1;
            ack_recv_delay <= 0;
            data_bit_count <= 0;
            next_data_q <= 0;
          end else if (data_bit_count == 4'b1001) begin
            if (next_data_q) begin
              SDA_out_q <= 0;  // acknowledge
              read_SDA_en <= 1;
              data_bit_count <= 0;
            end
          end else if (!SCL) begin
            data_out_q[data_bit_count] <= SDA;
            data_bit_count <= data_bit_count + 1;
            read_SDA_en <= (data_bit_count != 5'b00111);
            SDA_out_q <= 0; // acknowledge
          end
        end
        default: begin
        end
      endcase
    end
  end

  // always @(posedge SCL) begin
  //   if (state == `READ_DATA_BYTE && data_bit_count == 4'b1001) begin
  //     data_out <= data_out_q;
  //     next_data_q <= next_data;
  //   end

  // end
endmodule

