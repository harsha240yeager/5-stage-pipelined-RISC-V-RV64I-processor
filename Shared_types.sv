
// Shared_types.sv
// Common type definitions shared across CPU modules

package Shared_types;

  typedef enum logic [4:0] {
    // RV64I base
    ALU_ADD    = 5'd0,
    ALU_SUB    = 5'd1,
    ALU_AND    = 5'd2,
    ALU_OR     = 5'd3,
    ALU_XOR    = 5'd4,
    ALU_SLL    = 5'd5,
    ALU_SRL    = 5'd6,
    ALU_SRA    = 5'd7,
    ALU_SLT    = 5'd8,
    ALU_SLTU   = 5'd9,

    // Zba (address generation)
    ALU_SH1ADD = 5'd10,
    ALU_SH2ADD = 5'd11,
    ALU_SH3ADD = 5'd12,

    // RV64 *W (distinct, no reuse)
    ALU_ADDW   = 5'd13,
    ALU_SUBW   = 5'd14,
    ALU_SLLW   = 5'd15,
    ALU_SRLW   = 5'd16,
    ALU_SRAW   = 5'd17
  } alu_op_t;

endpackage : Shared_types
