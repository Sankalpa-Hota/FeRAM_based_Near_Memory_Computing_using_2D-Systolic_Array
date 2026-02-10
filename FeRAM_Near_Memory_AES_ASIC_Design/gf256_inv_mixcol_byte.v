// Written by Sankalpa Hota
// One byte of AES InvMixColumns (decrypt); ROW_IDX selects row of 0E,0B,0D,09 matrix.
module gf256_inv_mixcol_byte #(
  parameter ROW_IDX = 0
) (
  input  wire [7:0] s0, s1, s2, s3,
  output wire [7:0] byte_out
);
  wire [7:0] x2_0, x2_1, x2_2, x2_3, x4_0, x4_1, x4_2, x4_3, x8_0, x8_1, x8_2, x8_3;
  gf256_xtime u2_0 (.a(s0), .y(x2_0));
  gf256_xtime u2_1 (.a(s1), .y(x2_1));
  gf256_xtime u2_2 (.a(s2), .y(x2_2));
  gf256_xtime u2_3 (.a(s3), .y(x2_3));
  gf256_xtime u4_0 (.a(x2_0), .y(x4_0));
  gf256_xtime u4_1 (.a(x2_1), .y(x4_1));
  gf256_xtime u4_2 (.a(x2_2), .y(x4_2));
  gf256_xtime u4_3 (.a(x2_3), .y(x4_3));
  gf256_xtime u8_0 (.a(x4_0), .y(x8_0));
  gf256_xtime u8_1 (.a(x4_1), .y(x8_1));
  gf256_xtime u8_2 (.a(x4_2), .y(x8_2));
  gf256_xtime u8_3 (.a(x4_3), .y(x8_3));
  wire [7:0] m09_0 = x8_0 ^ s0, m09_1 = x8_1 ^ s1, m09_2 = x8_2 ^ s2, m09_3 = x8_3 ^ s3;
  wire [7:0] m0b_0 = x8_0 ^ x2_0 ^ s0, m0b_1 = x8_1 ^ x2_1 ^ s1, m0b_2 = x8_2 ^ x2_2 ^ s2, m0b_3 = x8_3 ^ x2_3 ^ s3;
  wire [7:0] m0d_0 = x8_0 ^ x4_0 ^ s0, m0d_1 = x8_1 ^ x4_1 ^ s1, m0d_2 = x8_2 ^ x4_2 ^ s2, m0d_3 = x8_3 ^ x4_3 ^ s3;
  wire [7:0] m0e_0 = x8_0 ^ x4_0 ^ x2_0, m0e_1 = x8_1 ^ x4_1 ^ x2_1, m0e_2 = x8_2 ^ x4_2 ^ x2_2, m0e_3 = x8_3 ^ x4_3 ^ x2_3;
  assign byte_out = (ROW_IDX == 0) ? (m0e_0 ^ m0b_1 ^ m0d_2 ^ m09_3) :
                    (ROW_IDX == 1) ? (m09_0 ^ m0e_1 ^ m0b_2 ^ m0d_3) :
                    (ROW_IDX == 2) ? (m0d_0 ^ m09_1 ^ m0e_2 ^ m0b_3) :
                    (m0b_0 ^ m0d_1 ^ m09_2 ^ m0e_3);
endmodule
