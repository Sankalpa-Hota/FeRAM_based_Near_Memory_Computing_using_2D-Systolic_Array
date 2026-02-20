# PNM FeRAM AES RTL — Written by Sankalpa Hota

Modular Verilog for a Processing-Near-Memory (PNM) AES-128 encrypt/decrypt engine using a 4×4 systolic array and a 1T-nC FeRAM-style memory interface. Supports Data protocol → FeRAM → NAND (encrypt for SSD write) and NAND → FeRAM → Data protocol (decrypt for host read).
