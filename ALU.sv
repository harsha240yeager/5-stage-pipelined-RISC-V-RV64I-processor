// alu.sv - Arithmetic Logic Unit (enum-based)

import Shared_types::*;

module alu (
    input  logic [63:0] op1,
    input  logic [63:0] op2,
    input  alu_op_t     alu_ctrl,
    output logic [63:0] result
);

    always_comb begin
        result = 64'b0;

        case (alu_ctrl)

            // ---------- RV64I ----------
            ALU_ADD:   result = op1 + op2;
            ALU_SUB:   result = op1 - op2;
            ALU_AND:   result = op1 & op2;
            ALU_OR:    result = op1 | op2;
            ALU_XOR:   result = op1 ^ op2;

            ALU_SLL:   result = op1 << op2[5:0];
            ALU_SRL:   result = op1 >> op2[5:0];
            ALU_SRA:   result = $signed(op1) >>> op2[5:0];

            ALU_SLT:   result = ($signed(op1) < $signed(op2)) ? 64'd1 : 64'd0;
            ALU_SLTU:  result = (op1 < op2) ? 64'd1 : 64'd0;

            // ---------- Zba ----------
            ALU_SH1ADD: result = (op1 << 1) + op2;
            ALU_SH2ADD: result = (op1 << 2) + op2;
            ALU_SH3ADD: result = (op1 << 3) + op2;

            // ---------- RV64 *W ----------
            ALU_ADDW: begin
                automatic logic [31:0] sum32;
                sum32  = op1[31:0] + op2[31:0];
                result = {{32{sum32[31]}}, sum32};
            end

            ALU_SUBW: begin
                automatic logic [31:0] diff32;
                diff32 = op1[31:0] - op2[31:0];
                result = {{32{diff32[31]}}, diff32};
            end

            ALU_SLLW: begin
                automatic logic [31:0] val32;
                val32  = op1[31:0] << op2[4:0];
                result = {{32{val32[31]}}, val32};
            end

            ALU_SRLW: begin
                automatic logic [31:0] val32;
                val32  = op1[31:0] >> op2[4:0];
                result = {32'b0, val32};
            end

            ALU_SRAW: begin
                automatic logic [31:0] val32;
                val32  = $signed(op1[31:0]) >>> op2[4:0];
                result = {{32{val32[31]}}, val32};
            end

            default: result = 64'b0;
        endcase
    end

endmodule

