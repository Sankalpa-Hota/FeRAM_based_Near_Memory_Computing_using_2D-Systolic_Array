`timescale 1ns/1ps
module aes_pnm_controller_tb;
  reg clk, rst_n, start, enc_dec;
  wire done, sra_en, mem_wr_en;
  wire [3:0] row_addr, mem_wr_row;
  wire pe_en, load_psum, shift_in_en, subbytes_sel, shiftrows_sel;
  wire [1:0] op_sel;
  wire [3:0] round;

  aes_pnm_controller #(.N_ROUNDS(10)) u_dut (
    .clk(clk), .rst_n(rst_n), .start(start), .enc_dec(enc_dec),
    .done(done), .sra_en(sra_en), .row_addr(row_addr),
    .mem_wr_en(mem_wr_en), .mem_wr_row(mem_wr_row),
    .pe_en(pe_en), .op_sel(op_sel), .load_psum(load_psum), .shift_in_en(shift_in_en),
    .round(round), .subbytes_sel(subbytes_sel), .shiftrows_sel(shiftrows_sel)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 0; start = 0; enc_dec = 1;
    #20 rst_n = 1;
    start = 1;
    #10 start = 0;
    wait (done);
    if (round !== 4'd10) $error("round count");
    $display("aes_pnm_controller_tb PASS");
    $finish;
  end

  initial begin
    #50000 $error("controller timeout");
    $finish;
  end
endmodule
