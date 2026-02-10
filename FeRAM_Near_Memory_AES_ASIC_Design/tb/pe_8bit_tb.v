`timescale 1ns/1ps
module pe_8bit_tb;
  reg clk, rst_n, pe_en, load_psum, shift_in_en;
  reg [1:0] op_sel;
  reg [7:0] data_n, data_w, key_byte;
  reg [7:0] mixcol_s0, mixcol_s1, mixcol_s2, mixcol_s3;
  wire [7:0] data_s, data_e, psum_out;

  pe_8bit #(.ID_X(0), .ID_Y(0)) u_dut (
    .clk(clk), .rst_n(rst_n), .pe_en(pe_en), .op_sel(op_sel),
    .load_psum(load_psum), .shift_in_en(shift_in_en),
    .data_n(data_n), .data_w(data_w), .key_byte(key_byte),
    .mixcol_s0(mixcol_s0), .mixcol_s1(mixcol_s1), .mixcol_s2(mixcol_s2), .mixcol_s3(mixcol_s3),
    .data_s(data_s), .data_e(data_e), .psum_out(psum_out)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 0; pe_en = 0; load_psum = 0; shift_in_en = 0; op_sel = 2'b00;
    data_n = 0; data_w = 0; key_byte = 0; mixcol_s0 = 0; mixcol_s1 = 0; mixcol_s2 = 0; mixcol_s3 = 0;
    #20 rst_n = 1;

    pe_en = 1; load_psum = 1; data_n = 8'hAB;
    #10;
    if (data_s !== 8'hAB) $error("load_psum");
    load_psum = 0; op_sel = 2'b01; key_byte = 8'h12;
    #10;
    if (data_s !== (8'hAB ^ 8'h12)) $error("XOR AddRoundKey");
    $display("pe_8bit_tb PASS");
    $finish;
  end
endmodule
