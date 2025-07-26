# Verilog-Based Single-Cycle CPU with Memory Hierarchy

This project implements a single-cycle CPU in Verilog, complete with a hierarchical memory subsystem including data memory, a data cache, and an instruction cache. The design was tested with simulated instruction sets and waveform verification using GTKWave.



## Features Overview

### 1. CPU Core
A custom-built single-cycle CPU capable of executing basic and intermediate-level instructions.

**Includes:**
- Register File with 8-bit registers
- ALU supporting arithmetic and logic operations
- Control unit for instruction decoding
- Immediate value handling and jump/branch logic
- Program counter and instruction fetch unit

**Supported Instruction Types:**
- Arithmetic (e.g., `add`, `sub`)
- Logical (e.g., `and`, `or`)
- Branching (`beq`, `bne`)
- Jump and Jump Register
- Immediate Operations



### 2. Data Memory
An external memory module was integrated to allow data read and write operations from/to memory addresses.

**Key Details:**
- 256 Bytes total size
- Byte-addressable memory
- Controlled by `READ`, `WRITE`, `BUSYWAIT`, and address/data lines
- Introduced four memory access instructions:
  - `lwd` – Load from memory using register
  - `lwi` – Load from memory using immediate address
  - `swd` – Store to memory using register
  - `swi` – Store to memory using immediate address
- CPU stalls execution when `BUSYWAIT` is asserted by memory



### 3. Data Cache
To reduce data access latency, a direct-mapped cache was placed between the CPU and data memory.

**Specifications:**
- Cache size: 32 Bytes
- Block size: 4 Bytes (8 blocks)
- Direct-mapped placement strategy
- Valid, Dirty, and Tag bits for each block
- Write-back and write-allocate policy
- Finite State Machine (FSM) to handle:
  - Read/Write Misses
  - Write-back of dirty blocks
  - Data block fetches from memory

**Performance:**
- Cache hit: 2 cycles
- Clean miss: 21 cycles
- Dirty miss: 42 cycles



### 4. Instruction Cache and Memory
To improve instruction fetch performance, a separate instruction memory and instruction cache were added.

**Instruction Cache Details:**
- Cache size: 128 Bytes
- Block size: 16 Bytes (8 blocks)
- Direct-mapped
- Valid and Tag bits (no dirty bits needed)
- Only supports read operations
- Miss penalty: 81 cycles

**Instruction Memory:**
- 1024 Bytes (holds 256 32-bit instructions)
- Accessed using a 10-bit program counter (word-aligned)
- Cache automatically fetches 16-byte blocks on miss



## How to Run the Project

1. Open the Verilog files in a simulator 
2. Compile the design and run the testbench.
3. View the signal behavior and instruction execution using GTKWave.
4. Use custom instruction programs to test different memory and cache behaviors.



## GTKWave Demonstrations

Below are sample waveform diagrams showcasing various parts of the system.

<img width="1667" height="719" alt="5 th instruction is a cache miss so again fetched another block of instructions from memory" src="https://github.com/user-attachments/assets/f56ed9fb-cd4b-468e-ab31-0e7959c849ce" />
<img width="1630" height="754" alt="first 4 instructions fetched to the cache from instruction memory" src="https://github.com/user-attachments/assets/dc86b499-40e9-4399-8381-fd7b14d142ac" />



