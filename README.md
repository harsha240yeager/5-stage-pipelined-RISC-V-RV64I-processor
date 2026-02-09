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


### Key Architectural Highlights
- Control signals are generated in the **ID stage**
- Zba instructions are decoded as **R-type** and executed in the **EX stage**
- **ID-stage bypassing** ensures correct execution of back-to-back dependent instructions without inserting NOPs
- Branch resolution and pipeline flushing are handled in the **EX stage**

A single-page pipeline diagram is available in the `docs/` directory.

---


### 📁 Repository Structure

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
│   └── hazard_detection_unit.sv
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


