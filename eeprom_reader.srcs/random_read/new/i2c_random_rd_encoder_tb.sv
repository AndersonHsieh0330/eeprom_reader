`timescale 1ns / 1ps

module i2c_random_rd_encoder_tb ();
  logic double_speed_scl_to_encoder = 0; // this is the system clk from ocsillator 
  logic SCL;  // this is the real SCL, does not toggle on idle state
  logic SCL_TO_ENCODER = 0;
  wire SDA;
  logic data_adr_en;
  logic [14:0] data_adr;
  logic device_adr_en;
  logic [2:0] device_adr;
  logic start;
  logic done;
  logic read_en = 1;
  logic SDA_q = 0;
  logic [3:0] bit_count = 0;;

  assign SDA = ~read_en ? SDA_q : 1'bz;

  always begin
    #0.5 double_speed_scl_to_encoder = ~double_speed_scl_to_encoder;
  end
  always @(posedge double_speed_scl_to_encoder) begin
    SCL_TO_ENCODER <= ~SCL_TO_ENCODER;
  end

  always_ff @(negedge double_speed_scl_to_encoder) begin
    if (~(SCL | done)) begin
      bit_count <= bit_count + 1;
      if (bit_count == 8) begin
        read_en <= 0;
        SDA_q <= 0; // acknolwedge
      end else if (bit_count == 9) begin
        bit_count <= 0;
      end
    end
  end
  // every #2 is a cycle of SCL
  initial begin
    data_adr_en <= 0;
    device_adr_en <= 0;
    start <= 0;
    done <= 1;
    #2; 
    start <= 1;
    data_adr <= {15{1'b1}};
    data_adr_en <= 1;
    device_adr <= {3{1'b1}};
    device_adr_en <= 1;
    #2
    start <= 0;
    // #16;  // start + control byte
    // read_en <= 0;
    // SDA_q <= 0;
    // #2;  //acknowledge
    // read_en <= 1;
    // #16;  // address byte HIGH
    // read_en <= 0;
    // SDA_q <= 0;
    // #2; //acknowledge
    // read_en <= 1;
    // #16; // address byte LOW
    // read_en <= 0;
    // SDA_q <= 0;
    // #2; //acknowledge
    // read_en <= 1;
    // #18; // start + control byte
    // read_en <= 0;
    // SDA_q <= 0;
    // #2;  //acknowledge


  end

  i2c_random_rd_encoder encoder_inst (
      .SCL_IN(SCL_TO_ENCODER),
      .SCL_OUT(SCL),
      .double_speed_scl(double_speed_scl_to_encoder),
      .*
  );
endmodule
