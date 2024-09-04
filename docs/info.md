<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->
# Pipelined LEGv8 Processor

## How it works

### Project Overview

This project implements a pipelined LEGv8 processor, designed in Verilog and synthesized for an ASIC tapeout. The processor follows the typical RISC architecture with a 5-stage pipeline, which includes:

#### Pipeline Stages

- **Instruction Fetch (IF):** Fetches instructions from the instruction memory based on the Program Counter (PC).
- **Instruction Decode (ID):** Decodes the instruction and reads the necessary registers from the register file.
- **Execute (EX):** Performs arithmetic and logical operations using the ALU and calculates branch target addresses.
- **Memory Access (MEM):** Accesses data memory for load and store instructions.
- **Write Back (WB):** Writes the results back to the register file.

#### Key Features

- **Pipelining:** The processor uses a 5-stage pipeline to increase instruction throughput, allowing multiple instructions to be processed simultaneously.
- **Hazard Detection & Forwarding:** Implemented to resolve data hazards and ensure correct data flow between pipeline stages.
- **Branch Prediction:** Simple branch prediction to handle control hazards.
- **ALU:** Supports basic arithmetic and logical operations.
- **Register File:** Contains 32 registers, accessible through two read ports and one write port.

## How to test

The Instruction Cache is loaded with instructions that successfully test all the instructions supported by the CPU.

| Line # | ARM Assembly         | Machine Code                                  | Hexadecimal  |
|--------|----------------------|-----------------------------------------------|--------------|
| 1      | `LDUR r2, [r10]`     | `1111 1000 0100 0000 0000 0001 0100 0010`     | `0xF8400142` |
| 2      | `LDUR r3, [r10, #1]` | `1111 1000 0100 0000 0001 0001 0100 0011`     | `0xF8401143` |
| 3      | `SUB r4, r3, r2`     | `1100 1011 0000 0010 0000 0000 0110 0100`     | `0xCB020064` |
| 4      | `ADD r5, r3, r2`     | `1000 1011 0000 0010 0000 0000 0110 0101`     | `0x8B020065` |
| 5      | `CBZ r1, #2`         | `1011 0100 0000 0000 0000 0000 0100 0001`     | `0xB4000041` |
| 6      | `CBZ r0, #2`         | `1011 0100 0000 0000 0000 0000 0100 0000`     | `0xB4000040` |
| 7      | `LDUR r2, [r10]`     | `1111 1000 0100 0000 0000 0001 0100 0010`     | `0xF8400142` |
| 8      | `ORR r6, r2, r3`     | `1010 1010 0000 0011 0000 0000 0100 0110`     | `0xAA030046` |
| 9      | `AND r7, r2, r3`     | `1000 1010 0000 0011 0000 0000 0100 0111`     | `0x8A030047` |
| 10     | `STUR r4, [r7, #1]`  | `1111 1000 0000 0000 0001 0000 1110 0100`     | `0xF80010E4` |
| 11     | `B #2`               | `0001 0100 0000 0000 0000 0000 0000 0011`     | `0x14000003` |
| 12     | `LDUR r3, [r10, #1]` | `1111 1000 0100 0000 0001 0001 0100 0011`     | `0xF8401143` |
| 13     | `ADD r8, r0, r1`     | `1000 1011 0000 0001 0000 0000 0000 1000`     | `0x8B010008` |


## External hardware

Still working on adding verilog to support external hardware in order to test the CPU once printed. 
