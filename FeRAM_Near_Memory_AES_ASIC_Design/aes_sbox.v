// Written by Sankalpa Hota
// AES S-Box LUT for encryption SubBytes (uses aes_sbox.hex).
module aes_sbox (
  input  wire [7:0] d,
  output wire [7:0] q
);
  reg [7:0] lut [0:255];
  initial $readmemh("aes_sbox.hex", lut);
  assign q = lut[d];
endmodule
