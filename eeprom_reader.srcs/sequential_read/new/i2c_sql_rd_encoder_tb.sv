`timescale 1ns / 1ps
module i2c_sql_rd_encoder_tb ();

  logic reset;
  logic data_start_adr_en;
  logic device_adr_en;
  logic double_speed_scl;
  logic SCL_GEN;
  logic SCL;
  logic next_data;
  logic [14:0] data_start_adr = 15'b0;
  logic [2:0] device_adr = 3'b0;
  logic [7:0] data_out;
  wire SDA;
  logic SDA_q;
  logic read_en;  //HIGH when master is outputing
  longint test_data = 64'b00000001_00000010_00000100_00001000_00010000_00100000_01000000_10000000;
  assign SDA = ~read_en ? SDA_q : 1'bz;

  always begin
    #0.5 double_speed_scl = ~double_speed_scl;
  end
  always @(posedge double_speed_scl) begin
    SCL_GEN <= ~SCL_GEN;
  end

  initial begin
    next_data = 0;
    double_speed_scl <= 0;
    SCL_GEN <= 0;
    data_start_adr <= {15{1'b1}};
    device_adr <= {3{1'b1}};
    data_start_adr_en <= 1;
    device_adr_en <= 1;
    reset <= 1;
    read_en <= 1;
    #2 reset <= 0;
    data_start_adr_en <= 0;
    device_adr_en <= 0;
    #18  // start + control byte
    read_en <= 0;
    SDA_q <= 0;
    #2  //acknowledge
    read_en <= 1;
    #16  // address byte HIGH
    read_en <= 0;
    SDA_q <= 0;
    #2  //acknowledge
    read_en <= 1;
    #16  // address byte LOW
    read_en <= 0;
    SDA_q <= 0;
    #2  //acknowledge
    read_en <= 1;
    #18  // start + control byte
    read_en <= 0;
    SDA_q <= 0;
    #2  //acknowledge

    // start sending data here, 8 bits, starting at 78ns in simulation
    for (int i = 0; i < 8; i = i + 1) begin
      next_data = 0;
      for (int j = 0; j < 8; j = j + 1) begin
        SDA_q <= test_data[8*i+j];
        #2;
      end
      read_en <= 1;
      assert (SDA == 0) else $error("first data acknowledge bit wrong"); 
      #2;
      read_en   <= 0;
    end
      next_data <= 1;
  end

  i2c_sql_rd_encoder encoder_inst (
    .SCL_IN(SCL_GEN),
    .SCL_OUT(SCL),
    .*
  );

endmodule
