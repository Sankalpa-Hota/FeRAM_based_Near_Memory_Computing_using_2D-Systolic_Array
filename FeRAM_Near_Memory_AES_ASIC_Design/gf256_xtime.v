// Written by Sankalpa Hota
// GF(2^8) multiply-by-02 (xtime) for AES MixColumns.
module gf256_xtime (
  input  wire [7:0] a,
  output wire [7:0] y
);
  assign y = a[7] ? ((a << 1) ^ 8'h1B) : (a << 1);
endmodule
