# RISC-V 5-Stage Pipelined Processor Core

This repository contains the SystemVerilog implementation of a 5-Stage Pipelined RISC-V (RV32I) Processor Core. The project is structured in two evolutionary versions—**RISCV** (Baseline Core) and **RISCV_2** (Extended Architecture)—to demonstrate how the datapath and control unit expand to support control-flow transfer and direct arithmetic operations.

---

## 📂 Architecture Overview

The design follows a classic 5-stage RISC-V pipelined microarchitecture:
1. **Instruction Fetch (IF):** Manages the Program Counter (PC) and retrieves instructions from `Instruction_Memory`.
2. **Instruction Decode (ID):** Extracts opcodes, reads from the Register File, generates immediate values, and decodes control configurations.
3. **Execute (EX):** Utilizes the primary Arithmetic Logic Unit (ALU) to compute arithmetic, logic operations, or target memory addresses.
4. **Memory Access (MEM):** Interacts with Data Memory for load/store commands.
5. **Write Back (WB):** Validates the `RegWrite` control flag to update computed results or memory data back into the Register File.

---

## ⚖️ Architectural Evolution: `RISCV` vs `RISCV_2`

### 1. Baseline Core (`RISCV`)
The baseline subdirectory houses the foundational pipelined execution pipeline, focusing on core R-Type computing instructions and simple data movement.
* **Supported Instructions:** Basic arithmetic (`ADD`, `SUB`), bitwise logic (`AND`, `OR`, `XOR`), and basic load/store addressing.
* **Limitations:** Lacks dynamic control branching and wide immediate parsing capabilities, limiting execution paths to linear instructions.

### 2. Advanced Core (`RISCV_2`)
The advanced iteration introduces dedicated logic to manage dynamic program execution and inline immediate constraints without stalling execution.

* **Immediate Instruction Support:** Integrates dedicated sign-extension and decoding paths for I-Type operations (`ADDI`, `ANDI`, `ORI`, `XORI`). This routes immediate operands dynamically into the ALU's second input multiplexer (`SrcB`), eliminating the need to pre-load constant values into staging registers.
* **Branch Instruction Support:** Implements standard B-Type conditional logic (`BEQ`, `BNE`, `BLT`, `BGE`). 
* **Early Branch Resolution:** To maintain low branch penalties, an auxiliary Sub-Decode ALU (**`sdALU`**) is positioned directly within the **Decode (ID) stage**. By resolving branch conditionals in the ID stage instead of waiting for the main Execute ALU, a taken branch only incurs a **1-cycle control hazard penalty** (flushing the single speculative instruction sitting in the Fetch stage), rather than a performance-degrading 2-cycle bubble.

---

## 🛠️ Verification and Simulation in QuestaSim

The processor is verified against functional programs compiled into hex code (e.g., `memfile.hex`). To simulate and check the core behavior inside Mentor Graphics **QuestaSim / ModelSim**, follow these steps:

### 1. File Path Resolution for `$readmemh`
The instruction memory initializes its state using `$readmemh("memfile.hex", mem);`. To prevent compilation errors indicating that the text file cannot be located:
* Verify your simulator's current running space by typing `pwd` into the QuestaSim console.
* Place your `memfile.hex` directly into that workspace directory, or declare a relative location path directly inside your SystemVerilog file (e.g., `../memfile.hex`).

### 2. Eliminating Array Bounds Mismatches
RISC-V memory indexes are absolute byte-addresses. To safely map a byte address into the internal word array of your instruction memory block without returning undefined (`X`) data states, the lowest 2 bits are dropped, and an appropriate upper bit-mask bound matching your array size is applied:
```systemverilog
assign RDd = (~rst) ? 32'b0 : mem[Aa[11:2]]; // Safely maps indices from 0 to 1023 for a 1024-word memory block
