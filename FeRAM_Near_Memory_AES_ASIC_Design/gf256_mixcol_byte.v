// Written by Sankalpa Hota
// One byte of AES MixColumns (encrypt); ROW_IDX selects row of the 02,03,01,01 matrix.
module gf256_mixcol_byte #(
  parameter ROW_IDX = 0
) (
  input  wire [7:0] s0, s1, s2, s3,
  output wire [7:0] byte_out
);
  wire [7:0] xt_s0, xt_s1, xt_s2, xt_s3;
  gf256_xtime u_xt0 (.a(s0), .y(xt_s0));
  gf256_xtime u_xt1 (.a(s1), .y(xt_s1));
  gf256_xtime u_xt2 (.a(s2), .y(xt_s2));
  gf256_xtime u_xt3 (.a(s3), .y(xt_s3));
  assign byte_out = (ROW_IDX == 0) ? (xt_s0 ^ xt_s1 ^ s1 ^ s2 ^ s3) :
                    (ROW_IDX == 1) ? (s0 ^ xt_s1 ^ xt_s2 ^ s2 ^ s3) :
                    (ROW_IDX == 2) ? (s0 ^ s1 ^ xt_s2 ^ xt_s3 ^ s3) :
                    (xt_s0 ^ s0 ^ s1 ^ s2 ^ xt_s3);
endmodule
