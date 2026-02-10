# PNM FeRAM AES RTL — Written by Sankalpa Hota

Modular Verilog for a Processing-Near-Memory (PNM) AES-128 encrypt/decrypt engine using a 4×4 systolic array and a 1T-nC FeRAM-style memory interface. Supports Data protocol → FeRAM → NAND (encrypt for SSD write) and NAND → FeRAM → Data protocol (decrypt for host read).

---

## Latest Architecture

```
                    state_init / state_init_en (e.g. from NVMe)
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│  aes_pnm_top                                                         │
│  ┌───────────────────┐   init_wr   ┌─────────────────────────────┐   │
│  │ Init FSM          │────────────▶│ feram_mem_interface         │   │
│  │ (4 cycles load    │             │ (SRA row read/write, 4B/row)│   │
│  │  state_init into  │◀────────────│ rd_data                     │   │
│  │  FeRAM)           │   sra_en,   └──────────────┬──────────────┘   │
│  └───────────────────┘   row_addr                 │                  │
│           │                                       │                  │
│           │              ┌────────────────────────▼───────  ────────┐│
│           │              │ data_n mux: mem_rd_data OR state_after_  ││
│           │              │ sbox (SubBytes/InvSubBytes by enc_dec)   ││
│           │              └──────────────────────────┬───────────────┘│
│           │                                         │                │
│  ┌────────▼────────┐                    ┌──────────▼──────────┐      │
│  │ aes_pnm_        │  sra_en, row_addr  │ systolic_array_4x4  │      │
│  │ controller      │  pe_en, op_sel,    │ (16× pe_8bit)       │      │
│  │ (Load→SubBytes  │  load_psum,        │ North: data_n       │      │
│  │  →MixCol/       │  subbytes_sel,     │ South: data_s       │      │
│  │  AddKey→Store)  │  enc_dec, round    │ MixCol/InvMixCol    │      │
│  └─────────────────┘                    │ by enc_dec          │      │
│           │                             └──────────┬──────────┘      │
│           │ ctrl_mem_wr_*                  ctrl_mem_wr_data (by row) │
│           └──────────────────────────────────────────┘               │
│                                                                      │
│  state_out (128-bit result), round (for key schedule)                │
└──────────────────────────────────────────────────────────────────────┘
```

- **FeRAM memory**: Row-oriented; one row (4 bytes) read or written per cycle (Single-Row Activation, SRA). Holds the 16-byte AES state in rows 0–3.
- **Controller**: FSM drives Load (SRA rows 0–3 into PEs), SubBytes/InvSubBytes (enc_dec), MixColumns/InvMixColumns (skipped on last encrypt round and first/last decrypt round), AddRoundKey, then Store (PE rows back to FeRAM). Encrypt: round 0→9. Decrypt: round 10→0.
- **Systolic array**: 16 PEs in 4×4; each PE holds one byte (PSUM), does load, XOR (AddRoundKey), MixCol/InvMixCol (by enc_dec), or pass. Column outputs feed MixColumns/InvMixColumns within the array.
- **SubBytes/InvSubBytes**: 16× S-Box / Inv S-Box in parallel; top muxes memory read vs. S-Box output into array North (data_n) using subbytes_sel and enc_dec.
- **Keys**: 16 bytes per round supplied from outside; `round` output can drive external key schedule (K0..K10 for encrypt, K10..K0 for decrypt).

---

## Architecture in Detail

### FeRAM and 1T-nC model

- The design assumes a **FeRAM-style** array: **1T-nC** (one transistor per row, multiple bitlines per column). One logical **row** = one **row of the AES state** (4 bytes).
- Access is **row-only**: no random byte addressing. A **Single-Row Activation (SRA)** selects one row; that row’s 4 bytes appear on the read port. Writes are also one row (4 bytes) per cycle.
- The **feram_mem_interface** module implements this: `row_addr` selects the row, `sra_en` enables a read, `wr_en`/`wr_row`/`wr_data` perform a row write. So the “memory” facing the AES core is a row buffer backed by this interface.

### Load – Compute – Store

1. **Load**: Controller asserts SRA for rows 0, 1, 2, 3 in turn. Each row’s 4 bytes go from FeRAM (via `mem_rd_data`) to the **North** inputs of the corresponding row of the 4×4 PE array. So the full 16-byte state is loaded into the 16 PEs (each PE’s PSUM holds one byte) with no separate off-array RAM for the state during the round.
2. **Compute**: All steps of the round happen **inside the array**:
   - **SubBytes / InvSubBytes**: The 128-bit state from the PEs (South outputs) is passed through `subbytes_block` or `inv_subbytes_block` (selected by `enc_dec`). The result is fed back to the PEs via the **data_n** mux when `subbytes_sel` is high (no write-back to FeRAM first).
   - **MixColumns / InvMixColumns**: Each column of the 4×4 is one AES column. PEs use `op_sel = OP_MIXCOL` and `enc_dec` to choose MixCol or InvMixCol; operands are the column’s four bytes (from each PE’s South output). Result stays in the PE.
   - **AddRoundKey**: Each PE XORs its PSUM with the round-key byte (`op_sel = OP_XOR`).
3. **Store**: Controller writes the PE array back to FeRAM **row by row**: for each row index, the four PEs in that row drive `ctrl_mem_wr_data`; the top muxes this with init data and feeds `feram_mem_interface` so the state is written one row per cycle.

So data moves **FeRAM → PEs → (SubBytes/MixCol/AddKey in PEs) → FeRAM**. Compute is adjacent to the FeRAM interface (PNM).

### Initialization (state_init)

- Before the first round, the host (e.g. NVMe side) must load the 128-bit block (plaintext or ciphertext) into FeRAM. The top provides **state_init** and **state_init_en**.
- When **state_init_en** is high, an init FSM writes **state_init** into the FeRAM rows over 4 cycles (one 32-bit row per cycle), using `init_wr_en` / `init_wr_row` / `init_wr_data`. The main controller’s write ports are muxed with these so init and round store do not conflict. After 4 cycles, the block is in FeRAM and the host can assert **start** for encrypt or decrypt.

---

## Interaction with NVMe and NAND (Data Path)

The RTL does not implement NVMe or NAND; it is the **AES engine** that sits between “host data” and “storage data.” The system view is:

- **Write path (host → SSD)**  
  1. **NVMe** (over PCIe) delivers a 128-bit plaintext block to the system.  
  2. That block is written into **FeRAM** via **state_init** and **state_init_en** (e.g. an NVMe/controller wrapper drives these for one block).  
  3. The controller runs **encrypt** (`enc_dec = 1`).  
  4. The result appears on **state_out** (ciphertext) and is then sent to **NAND** (SSD flash) for storage.

- **Read path (SSD → host)**  
  1. **NAND** supplies a 128-bit ciphertext block (data read from flash).  
  2. That block is written into **FeRAM** via **state_init** / **state_init_en** (e.g. the same wrapper loads “NAND read” data into the core).  
  3. The controller runs **decrypt** (`enc_dec = 0`).  
  4. The result on **state_out** (plaintext) is sent back via **NVMe**/PCIe to the host.

So **FeRAM** is the working buffer: data enters from NVMe (write) or from NAND (read), is encrypted or decrypted in place using the systolic array, and the result is either sent to NAND (encrypt) or back to NVMe (decrypt). The testbench **nvme_feram_nand_tb** simulates this: load plaintext → encrypt → capture “NAND” ciphertext → load ciphertext → decrypt → compare “NVMe” output to original plaintext.

---

## Controller: New Implementations

- **enc_dec**:  
  - **Encrypt** (`enc_dec = 1`): Round index **0 → 9**. SubBytes, MixColumns (skipped when `round == 9`), AddRoundKey each round.  
  - **Decrypt** (`enc_dec = 0`): Round index **10 → 0**. InvSubBytes, InvMixColumns (skipped when `round == 10` or `round == 0`), AddRoundKey each round.

- **Round counter**:  
  - On **start**, encrypt loads `round = 0`, decrypt loads `round = N_ROUNDS` (10).  
  - In **S_NEXT_ROUND**, encrypt does `round <= round + 1`; decrypt does `round <= round - 1`.  
  - Done when encrypt has finished round 9 (next would be 10) or decrypt has finished round 0.

- **SubBytes / MixCol skip**:  
  - In **S_SUBBYTES**, next state is **S_ADDKEY** (skip MixCol) when:  
    - Encrypt: `round == N_ROUNDS - 1`.  
    - Decrypt: `round == 0` or `round == N_ROUNDS`.  
  - Otherwise next state is **S_MIXCOL**.

- **Same FSM** for both directions; datapath (SubBytes vs InvSubBytes, MixCol vs InvMixCol) is selected by **enc_dec** in the top and in the PEs.

---

## Data Path Summary

| Stage        | Source of data_n (North into PEs)     | PE operation              | Sink                    |
|-------------|----------------------------------------|---------------------------|-------------------------|
| Load        | FeRAM `mem_rd_data` (by row_addr)     | load_psum                 | PSUM in each PE         |
| SubBytes    | state_after_sb / state_after_inv_sb   | load_psum                 | PSUM                    |
| MixCol      | (unchanged; column from data_s)       | op_sel = OP_MIXCOL        | PSUM                    |
| AddRoundKey | (unchanged)                           | op_sel = OP_XOR           | PSUM                    |
| Store       | —                                     | —                         | FeRAM via ctrl_mem_wr_* |

- **state_out**: Always the current 128-bit state formed from the South outputs of the 16 PEs (same as “state_from_array”). So when **done** is high, **state_out** is the ciphertext (encrypt) or plaintext (decrypt).
- **Round keys**: Supplied on **key_00..key_33** from outside; the **round** output can be used to select the correct key for the current round (K0..K10 for encrypt, K10..K0 for decrypt).

---

## How Encryption Happens

1. **Setup**: Host (NVMe) provides a 128-bit plaintext. It is loaded into FeRAM by asserting **state_init_en** and presenting **state_init** for 4 cycles (init FSM writes 4 rows). **enc_dec = 1**, and the key inputs are set (e.g. per-round keys K0..K9 from key schedule).
2. **Start**: **start** is pulsed; controller leaves IDLE and begins round 0.
3. **Per round**:
   - **Load**: SRA rows 0–3; each row’s 4 bytes go to the North inputs of the corresponding PE row; PEs do **load_psum** so the 16-byte state is in the array.
   - **SubBytes**: Controller sets **subbytes_sel**; **data_n** comes from **state_after_sb** (output of **subbytes_block**). PEs again **load_psum**, so the state is replaced by S-Box output.
   - **MixColumns** (if not last round): **op_sel = OP_MIXCOL**; each PE computes one byte of the MixColumns matrix for its column (using **enc_dec = 1** → MixCol). Result written back into PSUM.
   - **AddRoundKey**: **op_sel = OP_XOR**; each PE XORs PSUM with its **key_byte**. Result in PSUM.
   - **Store**: Controller asserts **mem_wr_en** and **mem_wr_row** for rows 0–3; each row’s 4 PEs drive **ctrl_mem_wr_data**; data is written into FeRAM.
4. **Next round**: Controller goes to **S_NEXT_ROUND**, increments **round** (0→1…→9). Steps 3 repeat. For the last round (round 9), MixColumns is skipped (go from SubBytes to AddRoundKey).
5. **Done**: After round 9, controller enters **S_DONE** and asserts **done**. **state_out** holds the 128-bit ciphertext, which the system then sends to NAND (SSD).

Decryption is the same flow with **enc_dec = 0**: InvSubBytes, InvMixColumns (skipped first and last decrypt round), AddRoundKey, and round count 10 down to 0; key schedule should supply K10..K0.

---

## Module Hierarchy and Files

```
aes_pnm_top
├── aes_pnm_controller
├── feram_mem_interface
├── systolic_array_4x4
│   └── pe_8bit
│       ├── gf256_mixcol_byte
│       │   └── gf256_xtime
│       └── gf256_inv_mixcol_byte
│           └── gf256_xtime
├── subbytes_block (16 × aes_sbox)
└── inv_subbytes_block (16 × aes_inv_sbox)
```

| File | Description |
|------|-------------|
| gf256_xtime.v | GF(2^8) multiply-by-02 (xtime) |
| gf256_mixcol_byte.v | One byte of MixColumns (encrypt), ROW_IDX 0..3 |
| gf256_inv_mixcol_byte.v | One byte of InvMixColumns (decrypt), ROW_IDX 0..3 |
| aes_sbox.v | AES S-Box LUT (aes_sbox.hex) |
| aes_inv_sbox.v | AES inverse S-Box LUT (aes_inv_sbox.hex) |
| subbytes_block.v | 16-way SubBytes |
| inv_subbytes_block.v | 16-way InvSubBytes |
| pe_8bit.v | 8-bit PE: PSUM, XOR, MixCol/InvMixCol, pass |
| systolic_array_4x4.v | 4×4 systolic array of PEs |
| feram_mem_interface.v | FeRAM SRA row memory (4 bytes/row) |
| aes_pnm_controller.v | Load / SubBytes / MixCol / AddKey / Store FSM; enc_dec, round 0..9 or 10..0 |
| aes_pnm_top.v | Top: init FSM, FeRAM, controller, array, SubBytes/InvSubBytes mux; state_out, round |

---

## Usage and Parameters

- **Round keys**: Supplied externally (16 bytes per round). Key expansion not included; **round** output can drive a key-schedule or LUT.
- **Initial block**: Load via **state_init** and **state_init_en** (4 cycles) before asserting **start**.
- **Simulation**: Place **aes_sbox.hex** and **aes_inv_sbox.hex** in the same directory as the S-Box modules (or set path for `$readmemh`).
- **Parameters**: **aes_pnm_top**: N_ROUNDS (default 10). **feram_mem_interface**: ADDR_W, DATA_W, N_ROWS. **gf256_mixcol_byte** / **gf256_inv_mixcol_byte**: ROW_IDX (0..3). **pe_8bit**: ID_X, ID_Y (0..3).

Testbenches (including **nvme_feram_nand_tb** for the full NVMe→FeRAM→NAND→FeRAM→NVMe round-trip) are in the project **tb/** directory; see **tb/run_tb.sh** to run them.
