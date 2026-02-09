# 🧠 RV64I + Zba 5-Stage Pipelined Processor

This repository implements a **5-stage pipelined RISC-V processor** supporting the **RV64I base ISA** along with the **Zba address-generation extension** (`SH1ADD`, `SH2ADD`, `SH3ADD`).

The project was developed as part of the **LFX Mentorship Coding Challenge** and emphasizes **pipeline microarchitecture design, hazard resolution, and RTL-level verification**, all written in **SystemVerilog**.

---

## 🚀 Features

- **Classic 5-stage pipeline**  
  IF → ID → EX → MEM → WB
- **Full RV64I base instruction set**
- **Zba extension support**
  - `SH1ADD` : `(rs1 << 1) + rs2`
  - `SH2ADD` : `(rs1 << 2) + rs2`
  - `SH3ADD` : `(rs1 << 3) + rs2`
- **Comprehensive hazard handling**
  - EX-stage forwarding
  - **ID-stage bypassing** for two-source RAW hazards
  - Load-use hazard detection with pipeline stalling
- **Harvard architecture**
  - Separate instruction and data memories
- **Self-checking verification environment**
  - Automatic PASS / FAIL reporting
- Fully synthesizable **SystemVerilog RTL**

---

## 🏗️ Pipeline Overview

The processor follows a conventional 5-stage RISC pipeline:

IF → IF/ID → ID → ID/EX → EX → EX/MEM → MEM → MEM/WB → WB


### Architectural Highlights

- Control signals are generated in the **ID stage**
- **Zba instructions** are decoded as R-type and executed in the **EX stage**
- **ID-stage bypassing** allows correct execution of back-to-back dependent instructions without inserting NOPs
- Branch decisions and pipeline flushing are handled in the **EX stage**

A concise pipeline diagram is provided in the `docs/` directory.

---

## 🧪 Verification

Verification is performed using a **self-checking SystemVerilog testbench**.

### Test Program Coverage

- Integer arithmetic (`ADD`, `SUB`, `ADDI`)
- Memory operations (`LD`, `SD`)
- Control flow (`BLT`)
- All three **Zba instructions**
- Back-to-back dependent instructions to stress hazard logic

At the end of simulation, the testbench validates the architectural register file and reports:

ALL TESTS PASSED ✔



Any mismatch triggers a `$fatal`, ensuring deterministic and robust verification.

---

## 🧾 Test Program (C)

A reference C program (`test.c`) is included to demonstrate:

- Arithmetic operations
- Memory load / store behavior
- Branching logic
- Zba instruction usage

The complete build flow used to generate the instruction memory image is documented in `build_commands.txt`.

---

## 🔧 Build & Simulation

The design is intended to be simulated using **ModelSim / Questa**.

## 📌 Notes
This is not an OS-capable core

No CSR support, exceptions, or virtual memory

The design prioritizes pipeline correctness and hazard resolution over performance optimizations

Zba instructions are implemented in compliance with the RISC-V specification

## 🙌 Acknowledgments
Special thanks to Prof. Michael Dubois (University of Southern California) for foundational insights into processor pipeline architecture and hazard handling, which strongly influenced this design.

Additional thanks to ChatGPT for acting as a technical assistant throughout the design, debugging, and verification process 🙂

## 📬 Author
Harshavardhan Reddy Narra
Master’s in Electrical Engineering (Computer Architecture)

📧 Email: hnarra@usc.edu
🔗 LinkedIn: https://linkedin.com/in/harsha240
