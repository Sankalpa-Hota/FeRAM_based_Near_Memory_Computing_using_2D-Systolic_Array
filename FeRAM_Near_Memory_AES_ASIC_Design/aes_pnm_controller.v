// Written by Sankalpa Hota
// FSM: Load rows (SRA) -> SubBytes/InvSubBytes -> MixCol/InvMixCol (skip last/first+last) -> AddRoundKey -> Store; enc round 0..9, dec round 10..0.
module aes_pnm_controller #(
  parameter N_ROUNDS = 10
) (
  input  wire       clk,
  input  wire       rst_n,
  input  wire       start,
  input  wire       enc_dec,
  output reg        done,
  output reg        sra_en,
  output reg [3:0]  row_addr,
  output reg        mem_wr_en,
  output reg [3:0]  mem_wr_row,
  output reg        pe_en,
  output reg [1:0]  op_sel,
  output reg        load_psum,
  output reg        shift_in_en,
  output reg [3:0]  round,
  output reg        subbytes_sel,
  output reg        shiftrows_sel
);

  localparam S_IDLE        = 4'd0;
  localparam S_LOAD_ROW    = 4'd1;
  localparam S_SUBBYTES    = 4'd2;
  localparam S_MIXCOL      = 4'd3;
  localparam S_ADDKEY      = 4'd4;
  localparam S_STORE_ROW   = 4'd5;
  localparam S_NEXT_ROW    = 4'd6;
  localparam S_NEXT_ROUND  = 4'd7;
  localparam S_DONE        = 4'd8;

  localparam OP_NOP    = 2'b00;
  localparam OP_XOR    = 2'b01;
  localparam OP_MIXCOL = 2'b10;
  localparam OP_PASS   = 2'b11;

  reg [3:0] state, next_state;
  reg [3:0] row_cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state   <= S_IDLE;
      round   <= 4'd0;
      row_cnt <= 4'd0;
    end else begin
      state <= next_state;
      if (state == S_IDLE && start) begin
        round   <= enc_dec ? 4'd0 : (N_ROUNDS);
        row_cnt <= 4'd0;
      end else if (state == S_NEXT_ROW && next_state == S_LOAD_ROW)
        row_cnt <= row_cnt + 1'b1;
      else if (next_state == S_STORE_ROW)
        row_cnt <= 4'd0;
      else if (state == S_STORE_ROW && next_state == S_STORE_ROW)
        row_cnt <= row_cnt + 1'b1;
      else if (next_state == S_LOAD_ROW && state == S_NEXT_ROUND)
        row_cnt <= 4'd0;
      if (next_state == S_NEXT_ROUND)
        round <= enc_dec ? (round + 1'b1) : (round - 1'b1);
    end
  end

  always @(*) begin
    done = 1'b0;
    sra_en = 1'b0;
    row_addr = row_cnt;
    mem_wr_en = 1'b0;
    mem_wr_row = row_cnt;
    pe_en = 1'b0;
    op_sel = OP_NOP;
    load_psum = 1'b0;
    shift_in_en = 1'b0;
    subbytes_sel = 1'b0;
    shiftrows_sel = 1'b0;
    next_state = state;

    case (state)
      S_IDLE: begin
        if (start) next_state = S_LOAD_ROW;
      end

      S_LOAD_ROW: begin
        sra_en = 1'b1;
        row_addr = row_cnt;
        pe_en = 1'b1;
        load_psum = 1'b1;
        next_state = S_NEXT_ROW;
      end

      S_NEXT_ROW: begin
        if (row_cnt == 4'd3)
          next_state = S_SUBBYTES;
        else
          next_state = S_LOAD_ROW;
      end

      S_SUBBYTES: begin
        pe_en = 1'b1;
        load_psum = 1'b1;
        subbytes_sel = 1'b1;
        if (enc_dec)
          next_state = (round == N_ROUNDS - 1) ? S_ADDKEY : S_MIXCOL;
        else
          next_state = (round == 4'd0 || round == N_ROUNDS) ? S_ADDKEY : S_MIXCOL;
      end

      S_MIXCOL: begin
        pe_en = 1'b1;
        op_sel = OP_MIXCOL;
        next_state = S_ADDKEY;
      end

      S_ADDKEY: begin
        pe_en = 1'b1;
        op_sel = OP_XOR;
        next_state = S_STORE_ROW;
      end

      S_STORE_ROW: begin
        mem_wr_en = 1'b1;
        mem_wr_row = row_cnt;
        next_state = (row_cnt == 4'd3) ? S_NEXT_ROUND : S_STORE_ROW;
      end

      S_NEXT_ROUND: begin
        if (enc_dec) begin
          if (round >= N_ROUNDS - 1) next_state = S_DONE;
          else next_state = S_LOAD_ROW;
        end else begin
          if (round == 4'd0) next_state = S_DONE;
          else next_state = S_LOAD_ROW;
        end
      end

      S_DONE: begin
        done = 1'b1;
        next_state = S_IDLE;
      end

      default: next_state = S_IDLE;
    endcase
  end
endmodule
