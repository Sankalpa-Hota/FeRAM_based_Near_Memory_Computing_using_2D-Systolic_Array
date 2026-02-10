// Written by Sankalpa Hota
// 16-way SubBytes over 128-bit state (encryption).
module subbytes_block (
  input  wire [127:0] state_in,
  output wire [127:0] state_out
);
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : sbox_row
      aes_sbox u_sbox (
        .d(state_in[i*8 +: 8]),
        .q(state_out[i*8 +: 8])
      );
    end
  endgenerate
endmodule
