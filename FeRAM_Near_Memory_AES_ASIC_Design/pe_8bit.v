// Written by Sankalpa Hota
// 8-bit PE: PSUM register, XOR (AddRoundKey), MixColumns/InvMixColumns (enc_dec), pass.
module pe_8bit #(
  parameter ID_X = 0,
  parameter ID_Y = 0
) (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        pe_en,
  input  wire [1:0]  op_sel,
  input  wire        load_psum,
  input  wire        shift_in_en,
  input  wire [7:0]  data_n,
  input  wire [7:0]  data_w,
  input  wire [7:0]  key_byte,
  input  wire        enc_dec,
  input  wire [7:0]  mixcol_s0, mixcol_s1, mixcol_s2, mixcol_s3,
  output wire [7:0]  data_s,
  output wire [7:0]  data_e,
  output wire [7:0]  psum_out
);
  localparam OP_NOP       = 2'b00;
  localparam OP_XOR       = 2'b01;
  localparam OP_MIXCOL    = 2'b10;
  localparam OP_PASS      = 2'b11;

  reg [7:0] psum_r;
  wire [7:0] alu_result;
  wire [7:0] mixcol_byte, inv_mixcol_byte;
  wire [7:0] mixcol_out = enc_dec ? mixcol_byte : inv_mixcol_byte;

  gf256_mixcol_byte #(.ROW_IDX(ID_Y)) u_mixcol (
    .s0(mixcol_s0), .s1(mixcol_s1), .s2(mixcol_s2), .s3(mixcol_s3),
    .byte_out(mixcol_byte)
  );
  gf256_inv_mixcol_byte #(.ROW_IDX(ID_Y)) u_inv_mixcol (
    .s0(mixcol_s0), .s1(mixcol_s1), .s2(mixcol_s2), .s3(mixcol_s3),
    .byte_out(inv_mixcol_byte)
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      psum_r <= 8'd0;
    else if (pe_en) begin
      if (load_psum)
        psum_r <= data_n;
      else if (shift_in_en)
        psum_r <= data_w;
      else
        psum_r <= alu_result;
    end
  end

  assign alu_result =
    (op_sel == OP_XOR)    ? (psum_r ^ key_byte) :
    (op_sel == OP_MIXCOL) ? mixcol_out :
    (op_sel == OP_PASS)   ? data_w :
    psum_r;

  assign data_s   = psum_r;
  assign data_e   = psum_r;
  assign psum_out = psum_r;
endmodule
