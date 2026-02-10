`timescale 1ns/1ps
module feram_mem_interface_tb;
  reg clk, rst_n, sra_en, wr_en;
  reg [3:0] row_addr, wr_row;
  reg [31:0] wr_data;
  wire [31:0] rd_data;

  feram_mem_interface #(.ADDR_W(4), .DATA_W(8), .N_ROWS(16)) u_dut (
    .clk(clk), .rst_n(rst_n), .sra_en(sra_en), .row_addr(row_addr),
    .wr_en(wr_en), .wr_row(wr_row), .wr_data(wr_data), .rd_data(rd_data)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    rst_n = 0; sra_en = 0; wr_en = 0; row_addr = 0; wr_row = 0; wr_data = 0;
    #20 rst_n = 1;

    wr_en = 1; wr_row = 0; wr_data = 32'hDDCCBBAA;
    #10;
    wr_en = 0; sra_en = 1; row_addr = 0;
    #10;
    if (rd_data !== 32'hDDCCBBAA) $error("SRA read row0");
    sra_en = 0; wr_en = 1; wr_row = 2; wr_data = 32'h11223344;
    #10;
    wr_en = 0; sra_en = 1; row_addr = 2;
    #10;
    if (rd_data !== 32'h11223344) $error("SRA read row2");
    $display("feram_mem_interface_tb PASS");
    $finish;
  end
endmodule
