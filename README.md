# 🧠 RV64I + Zba 5-Stage Pipelined Processor

This repository contains a **5-stage pipelined RISC-V processor** implementing the **RV64I base ISA** with support for the **Zba address-generation extension** (`SH1ADD`, `SH2ADD`, `SH3ADD`).  
The project was developed as part of the **LFX Mentorship Coding Challenge** and focuses on pipeline microarchitecture, hazard handling, and RTL verification using SystemVerilog.

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
- **Self-checking testbench** with automatic PASS/FAIL
- Synthesizable **SystemVerilog RTL**

---

## 🏗️ Pipeline Overview

The processor follows a classic 5-stage RISC pipeline:


