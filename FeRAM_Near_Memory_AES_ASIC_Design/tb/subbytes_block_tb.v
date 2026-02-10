`timescale 1ns/1ps
module subbytes_block_tb;
  reg [127:0] state_in;
  wire [127:0] state_out;

  subbytes_block u_dut (.state_in(state_in), .state_out(state_out));

  initial begin
    state_in = 128'h00112233445566778899aabbccddeeff;
    #10;
    if (state_out[7:0]   !== 8'h63) $error("byte0");
    if (state_out[127:120] !== 8'h16) $error("byte15");
    $display("subbytes_block_tb PASS");
    $finish;
  end
endmodule
