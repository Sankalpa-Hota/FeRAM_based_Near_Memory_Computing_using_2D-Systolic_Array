// Written by Sankalpa Hota
// 4x4 systolic array of PEs; North from memory/SubBytes, West row-shift; MixColumns by column.
module systolic_array_4x4 (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        pe_en,
  input  wire [1:0]  op_sel,
  input  wire        load_psum,
  input  wire        shift_in_en,
  input  wire        enc_dec,
  input  wire [7:0]  data_n_00, data_n_01, data_n_02, data_n_03,
  input  wire [7:0]  data_n_10, data_n_11, data_n_12, data_n_13,
  input  wire [7:0]  data_n_20, data_n_21, data_n_22, data_n_23,
  input  wire [7:0]  data_n_30, data_n_31, data_n_32, data_n_33,
  input  wire [7:0]  key_00, key_01, key_02, key_03,
  input  wire [7:0]  key_10, key_11, key_12, key_13,
  input  wire [7:0]  key_20, key_21, key_22, key_23,
  input  wire [7:0]  key_30, key_31, key_32, key_33,
  output wire [7:0]  data_s_00, data_s_01, data_s_02, data_s_03,
  output wire [7:0]  data_s_10, data_s_11, data_s_12, data_s_13,
  output wire [7:0]  data_s_20, data_s_21, data_s_22, data_s_23,
  output wire [7:0]  data_s_30, data_s_31, data_s_32, data_s_33
);

  wire [7:0] w_00_01, w_01_02, w_02_03;
  wire [7:0] w_10_11, w_11_12, w_12_13;
  wire [7:0] w_20_21, w_21_22, w_22_23;
  wire [7:0] w_30_31, w_31_32, w_32_33;

  pe_8bit #(.ID_X(0),.ID_Y(0)) u_00 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_00), .data_w(8'b0), .key_byte(key_00), .enc_dec(enc_dec),
    .mixcol_s0(data_s_00), .mixcol_s1(data_s_10), .mixcol_s2(data_s_20), .mixcol_s3(data_s_30),
    .data_s(data_s_00), .data_e(w_00_01), .psum_out()
  );
  pe_8bit #(.ID_X(1),.ID_Y(0)) u_01 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_01), .data_w(w_00_01), .key_byte(key_01), .enc_dec(enc_dec),
    .mixcol_s0(data_s_01), .mixcol_s1(data_s_11), .mixcol_s2(data_s_21), .mixcol_s3(data_s_31),
    .data_s(data_s_01), .data_e(w_01_02), .psum_out()
  );
  pe_8bit #(.ID_X(2),.ID_Y(0)) u_02 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_02), .data_w(w_01_02), .key_byte(key_02), .enc_dec(enc_dec),
    .mixcol_s0(data_s_02), .mixcol_s1(data_s_12), .mixcol_s2(data_s_22), .mixcol_s3(data_s_32),
    .data_s(data_s_02), .data_e(w_02_03), .psum_out()
  );
  pe_8bit #(.ID_X(3),.ID_Y(0)) u_03 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_03), .data_w(w_02_03), .key_byte(key_03), .enc_dec(enc_dec),
    .mixcol_s0(data_s_03), .mixcol_s1(data_s_13), .mixcol_s2(data_s_23), .mixcol_s3(data_s_33),
    .data_s(data_s_03), .data_e(), .psum_out()
  );

  pe_8bit #(.ID_X(0),.ID_Y(1)) u_10 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_10), .data_w(8'b0), .key_byte(key_10), .enc_dec(enc_dec),
    .mixcol_s0(data_s_00), .mixcol_s1(data_s_10), .mixcol_s2(data_s_20), .mixcol_s3(data_s_30),
    .data_s(data_s_10), .data_e(w_10_11), .psum_out()
  );
  pe_8bit #(.ID_X(1),.ID_Y(1)) u_11 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_11), .data_w(w_10_11), .key_byte(key_11), .enc_dec(enc_dec),
    .mixcol_s0(data_s_01), .mixcol_s1(data_s_11), .mixcol_s2(data_s_21), .mixcol_s3(data_s_31),
    .data_s(data_s_11), .data_e(w_11_12), .psum_out()
  );
  pe_8bit #(.ID_X(2),.ID_Y(1)) u_12 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_12), .data_w(w_11_12), .key_byte(key_12), .enc_dec(enc_dec),
    .mixcol_s0(data_s_02), .mixcol_s1(data_s_12), .mixcol_s2(data_s_22), .mixcol_s3(data_s_32),
    .data_s(data_s_12), .data_e(w_12_13), .psum_out()
  );
  pe_8bit #(.ID_X(3),.ID_Y(1)) u_13 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_13), .data_w(w_12_13), .key_byte(key_13), .enc_dec(enc_dec),
    .mixcol_s0(data_s_03), .mixcol_s1(data_s_13), .mixcol_s2(data_s_23), .mixcol_s3(data_s_33),
    .data_s(data_s_13), .data_e(), .psum_out()
  );

  pe_8bit #(.ID_X(0),.ID_Y(2)) u_20 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_20), .data_w(8'b0), .key_byte(key_20), .enc_dec(enc_dec),
    .mixcol_s0(data_s_00), .mixcol_s1(data_s_10), .mixcol_s2(data_s_20), .mixcol_s3(data_s_30),
    .data_s(data_s_20), .data_e(w_20_21), .psum_out()
  );
  pe_8bit #(.ID_X(1),.ID_Y(2)) u_21 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_21), .data_w(w_20_21), .key_byte(key_21), .enc_dec(enc_dec),
    .mixcol_s0(data_s_01), .mixcol_s1(data_s_11), .mixcol_s2(data_s_21), .mixcol_s3(data_s_31),
    .data_s(data_s_21), .data_e(w_21_22), .psum_out()
  );
  pe_8bit #(.ID_X(2),.ID_Y(2)) u_22 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_22), .data_w(w_21_22), .key_byte(key_22), .enc_dec(enc_dec),
    .mixcol_s0(data_s_02), .mixcol_s1(data_s_12), .mixcol_s2(data_s_22), .mixcol_s3(data_s_32),
    .data_s(data_s_22), .data_e(w_22_23), .psum_out()
  );
  pe_8bit #(.ID_X(3),.ID_Y(2)) u_23 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_23), .data_w(w_22_23), .key_byte(key_23), .enc_dec(enc_dec),
    .mixcol_s0(data_s_03), .mixcol_s1(data_s_13), .mixcol_s2(data_s_23), .mixcol_s3(data_s_33),
    .data_s(data_s_23), .data_e(), .psum_out()
  );

  pe_8bit #(.ID_X(0),.ID_Y(3)) u_30 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_30), .data_w(8'b0), .key_byte(key_30), .enc_dec(enc_dec),
    .mixcol_s0(data_s_00), .mixcol_s1(data_s_10), .mixcol_s2(data_s_20), .mixcol_s3(data_s_30),
    .data_s(data_s_30), .data_e(w_30_31), .psum_out()
  );
  pe_8bit #(.ID_X(1),.ID_Y(3)) u_31 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_31), .data_w(w_30_31), .key_byte(key_31), .enc_dec(enc_dec),
    .mixcol_s0(data_s_01), .mixcol_s1(data_s_11), .mixcol_s2(data_s_21), .mixcol_s3(data_s_31),
    .data_s(data_s_31), .data_e(w_31_32), .psum_out()
  );
  pe_8bit #(.ID_X(2),.ID_Y(3)) u_32 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_32), .data_w(w_31_32), .key_byte(key_32), .enc_dec(enc_dec),
    .mixcol_s0(data_s_02), .mixcol_s1(data_s_12), .mixcol_s2(data_s_22), .mixcol_s3(data_s_32),
    .data_s(data_s_32), .data_e(w_32_33), .psum_out()
  );
  pe_8bit #(.ID_X(3),.ID_Y(3)) u_33 (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n_33), .data_w(w_32_33), .key_byte(key_33), .enc_dec(enc_dec),
    .mixcol_s0(data_s_03), .mixcol_s1(data_s_13), .mixcol_s2(data_s_23), .mixcol_s3(data_s_33),
    .data_s(data_s_33), .data_e(), .psum_out()
  );

endmodule
