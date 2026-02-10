`timescale 1ns/1ps
module systolic_array_4x4_tb;
  reg clk, rst_n, pe_en, load_psum, shift_in_en;
  reg [1:0] op_sel;
  reg [7:0] data_n_00, data_n_01, data_n_02, data_n_03;
  reg [7:0] data_n_10, data_n_11, data_n_12, data_n_13;
  reg [7:0] data_n_20, data_n_21, data_n_22, data_n_23;
  reg [7:0] data_n_30, data_n_31, data_n_32, data_n_33;
  reg [7:0] key_00, key_01, key_02, key_03, key_10, key_11, key_12, key_13;
  reg [7:0] key_20, key_21, key_22, key_23, key_30, key_31, key_32, key_33;
  wire [7:0] data_s_00, data_s_01, data_s_02, data_s_03;
  wire [7:0] data_s_10, data_s_11, data_s_12, data_s_13;
  wire [7:0] data_s_20, data_s_21, data_s_22, data_s_23;
  wire [7:0] data_s_30, data_s_31, data_s_32, data_s_33;

  systolic_array_4x4 u_dut (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel),
    .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n_00(data_n_00), .data_n_01(data_n_01), .data_n_02(data_n_02), .data_n_03(data_n_03),
    .data_n_10(data_n_10), .data_n_11(data_n_11), .data_n_12(data_n_12), .data_n_13(data_n_13),
    .data_n_20(data_n_20), .data_n_21(data_n_21), .data_n_22(data_n_22), .data_n_23(data_n_23),
    .data_n_30(data_n_30), .data_n_31(data_n_31), .data_n_32(data_n_32), .data_n_33(data_n_33),
    .key_00(key_00), .key_01(key_01), .key_02(key_02), .key_03(key_03),
    .key_10(key_10), .key_11(key_11), .key_12(key_12), .key_13(key_13),
    .key_20(key_20), .key_21(key_21), .key_22(key_22), .key_23(key_23),
    .key_30(key_30), .key_31(key_31), .key_32(key_32), .key_33(key_33),
    .data_s_00(data_s_00), .data_s_01(data_s_01), .data_s_02(data_s_02), .data_s_03(data_s_03),
    .data_s_10(data_s_10), .data_s_11(data_s_11), .data_s_12(data_s_12), .data_s_13(data_s_13),
    .data_s_20(data_s_20), .data_s_21(data_s_21), .data_s_22(data_s_22), .data_s_23(data_s_23),
    .data_s_30(data_s_30), .data_s_31(data_s_31), .data_s_32(data_s_32), .data_s_33(data_s_33)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 0; pe_en = 0; load_psum = 0; shift_in_en = 0; op_sel = 2'b00;
    data_n_00 = 0; data_n_01 = 0; data_n_02 = 0; data_n_03 = 0;
    data_n_10 = 0; data_n_11 = 0; data_n_12 = 0; data_n_13 = 0;
    data_n_20 = 0; data_n_21 = 0; data_n_22 = 0; data_n_23 = 0;
    data_n_30 = 0; data_n_31 = 0; data_n_32 = 0; data_n_33 = 0;
    key_00 = 0; key_01 = 0; key_02 = 0; key_03 = 0;
    key_10 = 0; key_11 = 0; key_12 = 0; key_13 = 0;
    key_20 = 0; key_21 = 0; key_22 = 0; key_23 = 0;
    key_30 = 0; key_31 = 0; key_32 = 0; key_33 = 0;
    #20 rst_n = 1;

    pe_en = 1; load_psum = 1;
    data_n_00 = 8'h11; data_n_01 = 8'h22; data_n_02 = 8'h33; data_n_03 = 8'h44;
    data_n_10 = 8'h55; data_n_11 = 8'h66; data_n_12 = 8'h77; data_n_13 = 8'h88;
    data_n_20 = 8'h99; data_n_21 = 8'hAA; data_n_22 = 8'hBB; data_n_23 = 8'hCC;
    data_n_30 = 8'hDD; data_n_31 = 8'hEE; data_n_32 = 8'hFF; data_n_33 = 8'h00;
    #10;
    if (data_s_00 !== 8'h11 || data_s_33 !== 8'h00) $error("load");
    load_psum = 0; op_sel = 2'b01;
    key_00 = 8'h01; key_01 = 8'h01; key_02 = 8'h01; key_03 = 8'h01;
    key_10 = 8'h01; key_11 = 8'h01; key_12 = 8'h01; key_13 = 8'h01;
    key_20 = 8'h01; key_21 = 8'h01; key_22 = 8'h01; key_23 = 8'h01;
    key_30 = 8'h01; key_31 = 8'h01; key_32 = 8'h01; key_33 = 8'h01;
    #10;
    if (data_s_00 !== (8'h11^8'h01) || data_s_33 !== (8'h00^8'h01)) $error("AddRoundKey");
    $display("systolic_array_4x4_tb PASS");
    $finish;
  end
endmodule
