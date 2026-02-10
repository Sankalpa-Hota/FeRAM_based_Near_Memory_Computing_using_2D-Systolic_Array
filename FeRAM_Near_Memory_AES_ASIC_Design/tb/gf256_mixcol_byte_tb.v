`timescale 1ns/1ps
module gf256_mixcol_byte_tb;
  reg [7:0] s0, s1, s2, s3;
  wire [7:0] byte_out;

  gf256_mixcol_byte #(.ROW_IDX(0)) u_dut (
    .s0(s0), .s1(s1), .s2(s2), .s3(s3),
    .byte_out(byte_out)
  );

  initial begin
    s0 = 8'h63; s1 = 8'h2F; s2 = 8'hAF; s3 = 8'hA2;
    #10;
    if (byte_out !== 8'hBA) $error("MixCol row0 expected 0xBA");
    $display("gf256_mixcol_byte_tb PASS");
    $finish;
  end
endmodule
