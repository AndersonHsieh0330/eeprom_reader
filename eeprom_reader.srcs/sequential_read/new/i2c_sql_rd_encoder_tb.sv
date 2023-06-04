`timescale 1ns / 1ps
module i2c_sql_rd_encoder_tb ();

  logic reset;
  logic data_start_adr_en;
  logic device_adr_en;
  logic CLK; 
  logic next_data;
  logic [14:0] data_start_adr = 15'b0;
  logic [ 2:0] device_adr = 3'b0;
  logic [ 7:0] data_out;
  wire SDA;
  logic SDA_q;
  logic read_en; //HIGH when master is outputing

  assign SDA = ~read_en ? SDA_q : 1'bz;

  always begin
    #1 CLK = ~CLK;
  end

  initial begin
    CLK <= 0;
    data_start_adr <= {15{1'b1}};
    device_adr <= {3{1'b1}};
    data_start_adr_en <= 1;
    device_adr_en <= 1;
    reset <= 1;
    read_en <= 1;
    #2
    reset <= 0;
    data_start_adr_en <= 0;
    device_adr_en <= 0;
    #16
    read_en <= 0;
    SDA_q <= 0; //acknowledge
  end

  i2c_sql_rd_encoder encoder_inst (
      .SCL(CLK),
      .*
  );

endmodule
