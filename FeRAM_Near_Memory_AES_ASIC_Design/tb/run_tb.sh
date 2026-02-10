#!/bin/bash
# Run from repository root (parent of tb/ and rtl/).
set -e
RTL="rtl/pnm_aes"
RUN() { iverilog -o sim -I "$RTL" "$@" && vvp sim; }

echo "=== gf256_xtime_tb ==="
RUN tb/gf256_xtime_tb.v "$RTL/gf256_xtime.v"

echo "=== gf256_mixcol_byte_tb ==="
RUN tb/gf256_mixcol_byte_tb.v "$RTL/gf256_mixcol_byte.v" "$RTL/gf256_xtime.v"

echo "=== feram_mem_interface_tb ==="
RUN tb/feram_mem_interface_tb.v "$RTL/feram_mem_interface.v"

echo "=== aes_pnm_controller_tb ==="
RUN tb/aes_pnm_controller_tb.v "$RTL/aes_pnm_controller.v"

echo "=== pe_8bit_tb ==="
RUN tb/pe_8bit_tb.v "$RTL/pe_8bit.v" "$RTL/gf256_mixcol_byte.v" "$RTL/gf256_xtime.v"

echo "=== systolic_array_4x4_tb ==="
RUN tb/systolic_array_4x4_tb.v "$RTL/systolic_array_4x4.v" "$RTL/pe_8bit.v" "$RTL/gf256_mixcol_byte.v" "$RTL/gf256_xtime.v"

echo "=== aes_sbox_tb (run from rtl/pnm_aes for aes_sbox.hex) ==="
(cd "$RTL" && iverilog -o sim -I . ../tb/aes_sbox_tb.v aes_sbox.v && vvp sim)

echo "=== subbytes_block_tb ==="
(cd "$RTL" && iverilog -o sim -I . ../tb/subbytes_block_tb.v subbytes_block.v aes_sbox.v && vvp sim)

echo "=== aes_pnm_top_tb (2 rounds) ==="
(cd "$RTL" && iverilog -o sim -I . ../tb/aes_pnm_top_tb.v aes_pnm_top.v aes_pnm_controller.v feram_mem_interface.v systolic_array_4x4.v pe_8bit.v gf256_mixcol_byte.v gf256_xtime.v subbytes_block.v aes_sbox.v && vvp sim)

echo "=== All tests PASS ==="
