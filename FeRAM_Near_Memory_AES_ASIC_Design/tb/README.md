# Testbenches for PNM AES RTL

All testbenches live in this folder. The RTL is in `../rtl/pnm_aes/`.

## Running with Icarus Verilog (iverilog)

From the **repository root** (parent of `tb/` and `rtl/`):

| Testbench | Command |
|-----------|--------|
| gf256_xtime | `iverilog -o sim -I rtl/pnm_aes tb/gf256_xtime_tb.v rtl/pnm_aes/gf256_xtime.v && vvp sim` |
| gf256_mixcol_byte | `iverilog -o sim -I rtl/pnm_aes tb/gf256_mixcol_byte_tb.v rtl/pnm_aes/gf256_mixcol_byte.v rtl/pnm_aes/gf256_xtime.v && vvp sim` |
| aes_sbox | Run from `rtl/pnm_aes` so `aes_sbox.hex` is found: `cd rtl/pnm_aes && iverilog -o sim -I . ../tb/aes_sbox_tb.v aes_sbox.v && vvp sim` |
| subbytes_block | `cd rtl/pnm_aes && iverilog -o sim -I . ../tb/subbytes_block_tb.v subbytes_block.v aes_sbox.v && vvp sim` |
| pe_8bit | `iverilog -o sim -I rtl/pnm_aes tb/pe_8bit_tb.v rtl/pnm_aes/pe_8bit.v rtl/pnm_aes/gf256_mixcol_byte.v rtl/pnm_aes/gf256_xtime.v && vvp sim` |
| systolic_array_4x4 | `iverilog -o sim -I rtl/pnm_aes tb/systolic_array_4x4_tb.v rtl/pnm_aes/systolic_array_4x4.v rtl/pnm_aes/pe_8bit.v rtl/pnm_aes/gf256_mixcol_byte.v rtl/pnm_aes/gf256_xtime.v && vvp sim` |
| feram_mem_interface | `iverilog -o sim -I rtl/pnm_aes tb/feram_mem_interface_tb.v rtl/pnm_aes/feram_mem_interface.v && vvp sim` |
| aes_pnm_controller | `iverilog -o sim -I rtl/pnm_aes tb/aes_pnm_controller_tb.v rtl/pnm_aes/aes_pnm_controller.v && vvp sim` |
| aes_pnm_top | Run from `rtl/pnm_aes` (needs aes_sbox.hex). Use `run_tb.sh` or run all RTL + tb from there. |

Alternatively use the provided **run_tb.sh** script (run from repo root).

## Files

| File | DUT |
|------|-----|
| gf256_xtime_tb.v | gf256_xtime |
| gf256_mixcol_byte_tb.v | gf256_mixcol_byte |
| aes_sbox_tb.v | aes_sbox |
| subbytes_block_tb.v | subbytes_block |
| pe_8bit_tb.v | pe_8bit |
| systolic_array_4x4_tb.v | systolic_array_4x4 |
| feram_mem_interface_tb.v | feram_mem_interface |
| aes_pnm_controller_tb.v | aes_pnm_controller |
| aes_pnm_top_tb.v | aes_pnm_top |

## Note on aes_sbox.hex

`aes_sbox.v` loads `aes_sbox.hex` with `$readmemh("aes_sbox.hex", lut)`. The path is relative to the **current working directory** when the simulation runs. For any test that pulls in `aes_sbox` (aes_sbox_tb, subbytes_block_tb, aes_pnm_top_tb), run `vvp sim` from `rtl/pnm_aes`, or copy `aes_sbox.hex` into the directory from which you run `vvp`.
