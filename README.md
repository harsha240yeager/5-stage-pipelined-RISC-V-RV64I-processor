# 🧠 RV64I + Zba 5-Stage Pipelined Processor

This repository contains a **5-stage pipelined RISC-V processor** implementing the **RV64I base ISA** with support for the **Zba address-generation extension** (`SH1ADD`, `SH2ADD`, `SH3ADD`).  
The project was developed as part of the **LFX Mentorship Coding Challenge** and focuses on **pipeline microarchitecture, hazard handling, and RTL verification** using SystemVerilog.

---

## 🚀 Features

- **5-stage pipeline**: IF / ID / EX / MEM / WB  
- **RV64I base instruction set**
- **Zba extension support**:
  - `SH1ADD` — `(rs1 << 1) + rs2`
  - `SH2ADD` — `(rs1 << 2) + rs2`
  - `SH3ADD` — `(rs1 << 3) + rs2`
- **Hazard handling**:
  - EX-stage forwarding
  - **ID-stage bypass** for two-source RAW hazards
  - Load-use hazard detection and stalling
- **Separate instruction and data memories**
- **Self-checking testbench** with automatic PASS / FAIL
- Fully synthesizable **SystemVerilog RTL**

---

## 🏗️ Pipeline Overview

The processor follows a classic 5-stage RISC pipeline:

IF → IF/ID → ID → ID/EX → EX → EX/MEM → MEM → MEM/WB → WB

markdown
Copy code

### Key Architectural Highlights
- Control signals are generated in the **ID stage**
- Zba instructions are decoded as **R-type** and executed in the **EX stage**
- **ID-stage bypassing** ensures correct execution of back-to-back dependent instructions without inserting NOPs
- Branch resolution and pipeline flushing are handled in the **EX stage**

A single-page pipeline diagram is available in the `docs/` directory.

## 📁 Repository Structure

```text
.
├── rtl
│   ├── cpu_top.sv
│   ├── alu.sv
│   ├── control_unit.sv
│   ├── program_counter.sv
│   ├── instruction_memory.sv
│   ├── data_memory.sv
│   ├── register_file.sv
│   ├── immediate_generator.sv
│   ├── if_id_pipeline_register.sv
│   ├── id_ex_pipeline_register.sv
│   ├── ex_mem_pipeline_register.sv
│   ├── mem_wb_pipeline_register.sv
│   ├── forwarding_unit.sv
│   ├── hazard_detection_unit.sv
│   └── shared_types.sv
│
├── tb
│   └── tb_processor.sv
│
├── software
│   ├── test.c
│   ├── instr2_mem_init.hex
│   └── build_commands.txt
│
├── docs
│   ├── pipeline_diagram.pdf
│   ├── module_hierarchy.txt
│   └── submission_explanation.txt
│
└── README.md

---

## 🧪 Verification

Verification is performed using a **self-checking SystemVerilog testbench**.

### Test Program Highlights
- Basic arithmetic (`ADD`, `SUB`, `ADDI`)
- Memory access (`LD`, `SD`)
- Branching logic (`if` → `BLT`)
- **Three distinct Zba instructions**
- Back-to-back dependent instructions to stress hazard handling

At the end of simulation, the testbench checks the architectural register file and prints:

ALL TESTS PASSED ✔

yaml
Copy code

Any mismatch triggers a `$fatal`, ensuring deterministic verification.

---

## 🧾 Test Program (C)

A C test program (`test.c`) is included to demonstrate:
- Arithmetic operations
- Memory load / store
- Branching logic
- Zba instruction usage

The build flow used to generate the instruction memory image is documented in `build_commands.txt`.

---

## 🔧 Build & Simulation

The processor is intended to be simulated using **ModelSim / Questa**.

Typical simulation flow:

```tcl
vlog *.sv
vsim work.tb_processor
run -all
Instruction memory initialization:

systemverilog
Copy code
$readmemh("instr2_mem_init.hex", dut.IMEM.memory);
📌 Notes
This is not an OS-capable core (no CSR, exceptions, or virtual memory)

The design focuses on pipeline correctness and hazard resolution, not performance optimization

Zba instructions are implemented according to the RISC-V specification

🙌 Acknowledgments
Special thanks to Prof. Michael Dubois (University of Southern California) for foundational insights into processor pipeline architecture and hazard handling, which influenced the overall microarchitectural design of this project.
Additional thanks to ChatGPT for acting as a technical assistant throughout the design, debugging, and verification process 🙂

📬 Author
Harshavardhan Reddy Narra
Master’s in Electrical Engineering (Computer Architecture)
📧 Email: hnarra@usc.edu
🔗 LinkedIn: https://linkedin.com/in/harsha240
