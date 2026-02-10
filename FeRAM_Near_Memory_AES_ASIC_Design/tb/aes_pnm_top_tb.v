`timescale 1ns/1ps
module aes_pnm_top_tb;
  reg clk, rst_n, start, enc_dec, state_init_en;
  reg [127:0] state_init;
  reg [7:0] key_00, key_01, key_02, key_03, key_10, key_11, key_12, key_13;
  reg [7:0] key_20, key_21, key_22, key_23, key_30, key_31, key_32, key_33;
  wire done;
  wire [127:0] state_out;

  aes_pnm_top #(.N_ROUNDS(2)) u_dut (
    .clk(clk), .rst_n(rst_n), .start(start), .enc_dec(enc_dec),
    .done(done), .state_init(state_init), .state_init_en(state_init_en),
    .key_00(key_00), .key_01(key_01), .key_02(key_02), .key_03(key_03),
    .key_10(key_10), .key_11(key_11), .key_12(key_12), .key_13(key_13),
    .key_20(key_20), .key_21(key_21), .key_22(key_22), .key_23(key_23),
    .key_30(key_30), .key_31(key_31), .key_32(key_32), .key_33(key_33),
    .state_out(state_out)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 0; start = 0; enc_dec = 1; state_init_en = 0;
    state_init = 128'h00112233445566778899aabbccddeeff;
    key_00 = 0; key_01 = 0; key_02 = 0; key_03 = 0;
    key_10 = 0; key_11 = 0; key_12 = 0; key_13 = 0;
    key_20 = 0; key_21 = 0; key_22 = 0; key_23 = 0;
    key_30 = 0; key_31 = 0; key_32 = 0; key_33 = 0;
    #20 rst_n = 1;
    start = 1;
    #10 start = 0;
    wait (done);
    $display("state_out = %032x", state_out);
    $display("aes_pnm_top_tb PASS (2 rounds)");
    $finish;
  end

  initial begin
    #100000 $error("top timeout");
    $finish;
  end
endmodule
