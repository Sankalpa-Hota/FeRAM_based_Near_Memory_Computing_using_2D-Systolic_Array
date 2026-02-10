// Written by Sankalpa Hota
// FeRAM-style row memory: Single-Row Activation (SRA) read, row write; 4 bytes per row.
module feram_mem_interface #(
  parameter ADDR_W     = 6,
  parameter DATA_W     = 8,
  parameter N_ROWS     = 16,
  parameter N_BITS     = 8
) (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        sra_en,
  input  wire [ADDR_W-1:0] row_addr,
  input  wire        wr_en,
  input  wire [ADDR_W-1:0] wr_row,
  input  wire [DATA_W*4-1:0] wr_data,
  output wire [DATA_W*4-1:0] rd_data
);

  reg [DATA_W-1:0] mem [0:N_ROWS*4-1];
  reg [DATA_W*4-1:0] rd_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      rd_reg <= 0;
    else begin
      if (sra_en)
        rd_reg <= { mem[row_addr*4+3], mem[row_addr*4+2], mem[row_addr*4+1], mem[row_addr*4+0] };
      if (wr_en)
        { mem[wr_row*4+3], mem[wr_row*4+2], mem[wr_row*4+1], mem[wr_row*4+0] } <= wr_data;
    end
  end

  integer k;
  initial for (k = 0; k < N_ROWS*4; k = k + 1) mem[k] = 8'd0;

  assign rd_data = rd_reg;
endmodule
