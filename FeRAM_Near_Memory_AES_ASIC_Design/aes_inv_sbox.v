// Written by Sankalpa Hota
// AES inverse S-Box LUT for decryption InvSubBytes (uses aes_inv_sbox.hex).
module aes_inv_sbox (
  input  wire [7:0] d,
  output wire [7:0] q
);
  reg [7:0] lut [0:255];
  initial $readmemh("aes_inv_sbox.hex", lut);
  assign q = lut[d];
endmodule
