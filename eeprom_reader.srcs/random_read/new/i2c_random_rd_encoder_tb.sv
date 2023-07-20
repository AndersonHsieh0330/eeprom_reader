`timescale 1ns / 1ps

module i2c_random_rd_encoder_tb ();
  logic reset;
  logic double_speed_scl_to_encoder; // this is the system clk from ocsillator 
  logic SCL;  // this is the real SCL, does not toggle on idle state
  logic SCL_TO_ENCODER;
  wire SDA;
  logic [14:0] data_adr;
  logic [2:0] device_adr;
  logic start;
  logic done;
  logic read_en;
  logic SDA_q;
  logic [3:0] bit_count;
  logic [7:0] data_out;

  assign SDA = ~read_en ? SDA_q : 1'bz;

  always begin
    #0.5 double_speed_scl_to_encoder = ~double_speed_scl_to_encoder;
  end
  always @(posedge double_speed_scl_to_encoder) begin
    SCL_TO_ENCODER <= ~SCL_TO_ENCODER;
  end

  initial begin
    // tb nets initialize, does not affect nets in encoder
    reset <= 0;
    double_speed_scl_to_encoder <= 0;
    SCL_TO_ENCODER <= 0;
    data_adr <= {15{1'b1}};
    device_adr <= {3{1'b1}};
    start <= 0;
    read_en <= 1;
    SDA_q <= 0;
    bit_count <= 0;     

    reset <= 1;
    #1; 
    reset <= 0;
    #1;
    start <= 1;
    #1;
    start <= 0;
    #1;

    #16;  // start + control byte
    read_en <= 0;
    SDA_q <= 0;
    #2; //acknowledge
    read_en <= 1;
    
    #16; // address byte HIGH
    read_en <= 0;
    SDA_q <= 0;
    #2; //acknowledge
    read_en <= 1;

    #16; // address byte LOW
    read_en <= 0;
    SDA_q <= 0;
    #2;  //acknowledge
    read_en <= 1;

    #18; // start + control byte
    read_en <= 0;
    SDA_q <= 0;
    #2; //acknowledge

    // start sending data
    for(int i = 0 ; i < 8 ; i = i + 1) begin
      SDA_q <= i[0];
      #2;
    end
    read_en <= 1;
    #2; // no acknowledge
    #2; // STOP bit


  end

  i2c_random_rd_encoder encoder_inst (
      .SCL_IN(SCL_TO_ENCODER),
      .SCL_OUT(SCL),
      .double_speed_scl(double_speed_scl_to_encoder),
      .*
  );
endmodule
