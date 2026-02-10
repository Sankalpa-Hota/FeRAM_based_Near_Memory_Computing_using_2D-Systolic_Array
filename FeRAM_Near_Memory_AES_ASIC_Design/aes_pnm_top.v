// Written by Sankalpa Hota
// Top: FeRAM init from state_init, controller, 4x4 array, SubBytes/InvSubBytes mux by enc_dec; state_out/round.
module aes_pnm_top #(
  parameter N_ROUNDS = 10
) (
  input  wire        clk,
  input  wire        rst_n,
  input  wire        start,
  input  wire        enc_dec,
  output wire        done,
  input  wire [127:0] state_init,
  input  wire        state_init_en,
  input  wire [7:0]  key_00, key_01, key_02, key_03,
  input  wire [7:0]  key_10, key_11, key_12, key_13,
  input  wire [7:0]  key_20, key_21, key_22, key_23,
  input  wire [7:0]  key_30, key_31, key_32, key_33,
  output wire [127:0] state_out,
  output wire [3:0]  round
);

  wire        sra_en;
  wire [3:0]  row_addr;
  wire        mem_wr_en;
  wire [3:0]  mem_wr_row;
  wire [31:0] mem_wr_data;
  wire        pe_en;
  wire [1:0]  op_sel;
  wire        load_psum;
  wire        shift_in_en;
  wire        subbytes_sel;

  wire [31:0] mem_rd_data;
  reg         init_done;
  reg [1:0]   init_cnt;
  wire        init_load = state_init_en && !init_done;
  wire        init_wr_en = init_load;
  wire [3:0]  init_wr_row = {2'b0, init_cnt};
  wire [31:0] init_wr_data = (init_cnt == 0) ? { state_init[31:24], state_init[23:16], state_init[15:8], state_init[7:0] } :
                             (init_cnt == 1) ? { state_init[63:56], state_init[55:48], state_init[47:40], state_init[39:32] } :
                             (init_cnt == 2) ? { state_init[95:88], state_init[87:80], state_init[79:72], state_init[71:64] } :
                             { state_init[127:120], state_init[119:112], state_init[111:104], state_init[103:96] };
  wire        ctrl_mem_wr_en;
  wire [3:0]  ctrl_mem_wr_row;
  wire [31:0] ctrl_mem_wr_data;

  wire [7:0]  data_n_00, data_n_01, data_n_02, data_n_03;
  wire [7:0]  data_n_10, data_n_11, data_n_12, data_n_13;
  wire [7:0]  data_n_20, data_n_21, data_n_22, data_n_23;
  wire [7:0]  data_n_30, data_n_31, data_n_32, data_n_33;

  wire [7:0]  data_s_00, data_s_01, data_s_02, data_s_03;
  wire [7:0]  data_s_10, data_s_11, data_s_12, data_s_13;
  wire [7:0]  data_s_20, data_s_21, data_s_22, data_s_23;
  wire [7:0]  data_s_30, data_s_31, data_s_32, data_s_33;

  wire [127:0] state_from_array;
  wire [127:0] state_after_sb;
  wire [127:0] state_after_inv_sb;

  assign state_from_array = {
    data_s_33, data_s_23, data_s_13, data_s_03,
    data_s_32, data_s_22, data_s_12, data_s_02,
    data_s_31, data_s_21, data_s_11, data_s_01,
    data_s_30, data_s_20, data_s_10, data_s_00
  };

  subbytes_block u_subbytes (
    .state_in(state_from_array),
    .state_out(state_after_sb)
  );
  inv_subbytes_block u_inv_subbytes (
    .state_in(state_from_array),
    .state_out(state_after_inv_sb)
  );

  assign state_out = state_from_array;

  wire [127:0] state_after_sbox = enc_dec ? state_after_sb : state_after_inv_sb;
  assign data_n_00 = subbytes_sel ? state_after_sbox[ 7: 0] : (row_addr==0 ? mem_rd_data[ 7: 0] : data_s_00);
  assign data_n_01 = subbytes_sel ? state_after_sbox[15: 8] : (row_addr==0 ? mem_rd_data[15: 8] : data_s_01);
  assign data_n_02 = subbytes_sel ? state_after_sbox[23:16] : (row_addr==0 ? mem_rd_data[23:16] : data_s_02);
  assign data_n_03 = subbytes_sel ? state_after_sbox[31:24] : (row_addr==0 ? mem_rd_data[31:24] : data_s_03);
  assign data_n_10 = subbytes_sel ? state_after_sbox[39:32] : (row_addr==1 ? mem_rd_data[ 7: 0] : data_s_10);
  assign data_n_11 = subbytes_sel ? state_after_sbox[47:40] : (row_addr==1 ? mem_rd_data[15: 8] : data_s_11);
  assign data_n_12 = subbytes_sel ? state_after_sbox[55:48] : (row_addr==1 ? mem_rd_data[23:16] : data_s_12);
  assign data_n_13 = subbytes_sel ? state_after_sbox[63:56] : (row_addr==1 ? mem_rd_data[31:24] : data_s_13);
  assign data_n_20 = subbytes_sel ? state_after_sbox[71:64] : (row_addr==2 ? mem_rd_data[ 7: 0] : data_s_20);
  assign data_n_21 = subbytes_sel ? state_after_sbox[79:72] : (row_addr==2 ? mem_rd_data[15: 8] : data_s_21);
  assign data_n_22 = subbytes_sel ? state_after_sbox[87:80] : (row_addr==2 ? mem_rd_data[23:16] : data_s_22);
  assign data_n_23 = subbytes_sel ? state_after_sbox[95:88] : (row_addr==2 ? mem_rd_data[31:24] : data_s_23);
  assign data_n_30 = subbytes_sel ? state_after_sbox[103:96] : (row_addr==3 ? mem_rd_data[ 7: 0] : data_s_30);
  assign data_n_31 = subbytes_sel ? state_after_sbox[111:104] : (row_addr==3 ? mem_rd_data[15: 8] : data_s_31);
  assign data_n_32 = subbytes_sel ? state_after_sbox[119:112] : (row_addr==3 ? mem_rd_data[23:16] : data_s_32);
  assign data_n_33 = subbytes_sel ? state_after_sbox[127:120] : (row_addr==3 ? mem_rd_data[31:24] : data_s_33);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      init_done  <= 0;
      init_cnt   <= 0;
    end else if (state_init_en && !init_done) begin
      if (init_cnt == 2'd3)
        init_done <= 1;
      init_cnt <= init_cnt + 1'b1;
    end else if (!state_init_en)
      init_done <= 0;
  end

  assign ctrl_mem_wr_data = (ctrl_mem_wr_row == 0) ? { data_s_03, data_s_02, data_s_01, data_s_00 } :
                           (ctrl_mem_wr_row == 1) ? { data_s_13, data_s_12, data_s_11, data_s_10 } :
                           (ctrl_mem_wr_row == 2) ? { data_s_23, data_s_22, data_s_21, data_s_20 } :
                           { data_s_33, data_s_32, data_s_31, data_s_30 };

  assign mem_wr_en   = init_wr_en ? 1'b1 : ctrl_mem_wr_en;
  assign mem_wr_row  = init_wr_en ? init_wr_row : ctrl_mem_wr_row;
  assign mem_wr_data = init_wr_en ? init_wr_data : ctrl_mem_wr_data;

  feram_mem_interface #(.ADDR_W(4), .DATA_W(8), .N_ROWS(16)) u_mem (
    .clk(clk),
    .rst_n(rst_n),
    .sra_en(sra_en),
    .row_addr(row_addr),
    .wr_en(mem_wr_en),
    .wr_row(mem_wr_row),
    .wr_data(mem_wr_data),
    .rd_data(mem_rd_data)
  );

  aes_pnm_controller #(.N_ROUNDS(N_ROUNDS)) u_ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .enc_dec(enc_dec),
    .done(done),
    .sra_en(sra_en),
    .row_addr(row_addr),
    .mem_wr_en(ctrl_mem_wr_en),
    .mem_wr_row(ctrl_mem_wr_row),
    .pe_en(pe_en),
    .op_sel(op_sel),
    .load_psum(load_psum),
    .shift_in_en(shift_in_en),
    .round(round),
    .subbytes_sel(subbytes_sel),
    .shiftrows_sel()
  );

  systolic_array_4x4 u_array (
    .clk(clk),
    .rst_n(rst_n),
    .pe_en(pe_en),
    .op_sel(op_sel),
    .load_psum(load_psum),
    .shift_in_en(shift_in_en),
    .enc_dec(enc_dec),
    .data_n_00(data_n_00), .data_n_01(data_n_01), .data_n_02(data_n_02), .data_n_03(data_n_03),
    .data_n_10(data_n_10), .data_n_11(data_n_11), .data_n_12(data_n_12), .data_n_13(data_n_13),
    .data_n_20(data_n_20), .data_n_21(data_n_21), .data_n_22(data_n_22), .data_n_23(data_n_23),
    .data_n_30(data_n_30), .data_n_31(data_n_31), .data_n_32(data_n_32), .data_n_33(data_n_33),
    .key_00(key_00), .key_01(key_01), .key_02(key_02), .key_03(key_03),
    .key_10(key_10), .key_11(key_11), .key_12(key_12), .key_13(key_13),
    .key_20(key_20), .key_21(key_21), .key_22(key_22), .key_23(key_23),
    .key_30(key_30), .key_31(key_31), .key_32(key_32), .key_33(key_33),
    .data_s_00(data_s_00), .data_s_01(data_s_01), .data_s_02(data_s_02), .data_s_03(data_s_03),
    .data_s_10(data_s_10), .data_s_11(data_s_11), .data_s_12(data_s_12), .data_s_13(data_s_13),
    .data_s_20(data_s_20), .data_s_21(data_s_21), .data_s_22(data_s_22), .data_s_23(data_s_23),
    .data_s_30(data_s_30), .data_s_31(data_s_31), .data_s_32(data_s_32), .data_s_33(data_s_33)
  );
endmodule
