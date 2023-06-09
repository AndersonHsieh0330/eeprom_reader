`timescale 1ns / 1ps
module i2c_sql_rd_encoder_tb ();

  logic reset;
  logic data_start_adr_en;
  logic device_adr_en;
  logic double_speed_scl;
  logic SCL;
  logic next_data;
  logic [14:0] data_start_adr = 15'b0;
  logic [2:0] device_adr = 3'b0;
  logic [7:0] data_out;
  wire SDA;
  logic SDA_q;
  logic read_en;  //HIGH when master is outputing

  assign SDA = ~read_en ? SDA_q : 1'bz;

  always begin
    #0.5 double_speed_scl = ~double_speed_scl;
  end
  always @(posedge double_speed_scl) begin
    SCL <= ~SCL;
  end

  initial begin
    double_speed_scl <= 0;
    SCL <= 0;
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

    // start sending data here, 8 bits
    SDA_q <= 1;
    #2 SDA_q <= 0;
    #2 SDA_q <= 0;
    #2 SDA_q <= 0;
    #2 SDA_q <= 0;
    #2 SDA_q <= 0;
    #2 SDA_q <= 0;
    #2 SDA_q <= 1;
    #2;

  end

  i2c_sql_rd_encoder encoder_inst (.*);

endmodule
