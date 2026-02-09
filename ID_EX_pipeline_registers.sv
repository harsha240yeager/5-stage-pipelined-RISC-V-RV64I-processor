// id_ex.sv - ID/EX Pipeline Register
// Holds outputs of decode stage for use in execute stage.
import Shared_types::*;
module id_ex (
    input  logic         clk,
    input  logic         reset,
    input  logic         flush,         // Flush/bubble: insert a NOP in EX stage
    input  logic         enable,        // NEW: when 0, hold previous outputs (stall)
    // Control signals and data from ID stage
    input  logic [63:0]  pc_in,         // PC of this instruction
    input  logic [63:0]  pc_plus4_in,   // PC+4 (for JAL/JALR link address)
    input  logic [63:0]  rs1_val_in,
    input  logic [63:0]  rs2_val_in,
    input  logic [63:0]  imm_in,
    input  logic [4:0]   rs1_idx_in,
    input  logic [4:0]   rs2_idx_in,
    input  logic [4:0]   rd_idx_in,
    input  alu_op_t      alu_ctrl_in,   // ALU control code
    input  logic         alu_src_in,    // ALUSrc control (1 if using imm as second operand)
    input  logic         branch_in,     // branch instruction flag
    input  logic         jal_in,        // JAL flag
    input  logic         jalr_in,       // JALR flag
    input  logic         mem_read_in,   // will read from data memory
    input  logic         mem_write_in,  // will write to data memory
    input  logic [2:0]   funct3_in,     // lower bits of instruction (for branch and memory size)
    input  logic         reg_write_in,  // will write to register file (at WB stage)
    input  logic [1:0]   mem_to_reg_in, // selects result source for WB (00=ALU, 01=Mem, 10=PC+4)
    // Outputs to EX stage (registered)
    output logic [63:0]  pc_out,
    output logic [63:0]  pc_plus4_out,
    output logic [63:0]  rs1_val_out,
    output logic [63:0]  rs2_val_out,
    output logic [63:0]  imm_out,
    output logic [4:0]   rs1_idx_out,
    output logic [4:0]   rs2_idx_out,
    output logic [4:0]   rd_idx_out,
    output alu_op_t      alu_ctrl_out,
    output logic         alu_src_out,
    output logic         branch_out,
    output logic         jal_out,
    output logic         jalr_out,
    output logic         mem_read_out,
    output logic         mem_write_out,
    output logic [2:0]   funct3_out,
    output logic         reg_write_out,
    output logic [1:0]   mem_to_reg_out
);
    // On flush, we insert a bubble (NOP) in EX stage by zeroing control signals (no effect)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out         <= 64'b0;
            pc_plus4_out   <= 64'b0;
            rs1_val_out    <= 64'b0;
            rs2_val_out    <= 64'b0;
            imm_out        <= 64'b0;
            rs1_idx_out    <= 5'b0;
            rs2_idx_out    <= 5'b0;
            rd_idx_out     <= 5'b0;
            alu_ctrl_out   <= ALU_ADD;
            alu_src_out    <= 1'b0;
            branch_out     <= 1'b0;
            jal_out        <= 1'b0;
            jalr_out       <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            funct3_out     <= 3'b0;
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 2'b0;
        end else if (flush) begin
    // On a flush we must neutralize *control* signals so EX acts like a NOP,
    // but we must NOT destroy operand identity or values ? keeping rs*_val_out
    // and rs*_idx_out intact preserves forwarding and correct ALU inputs.
    // Clear control signals only:
            alu_ctrl_out   <= ALU_ADD;
            alu_src_out    <= 1'b0;
            branch_out     <= 1'b0;
            jal_out        <= 1'b0;
            jalr_out       <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            funct3_out     <= 3'b0;
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 2'b0;
    // DO NOT change:
    // - rs1_val_out, rs2_val_out
    // - imm_out (optional depending on your design)
    // - rs1_idx_out, rs2_idx_out, rd_idx_out
    // - pc_out, pc_plus4_out
        end else if (enable) begin
            // Normal operation: latch inputs into outputs only when enabled
            rs1_val_out    <= rs1_val_in;
            rs2_val_out    <= rs2_val_in;
            imm_out        <= imm_in;
            pc_out         <= pc_in;
            pc_plus4_out   <= pc_plus4_in;
            rs1_idx_out    <= rs1_idx_in;
            rs2_idx_out    <= rs2_idx_in;
            rd_idx_out     <= rd_idx_in;
            alu_ctrl_out   <= alu_ctrl_in;
            alu_src_out    <= alu_src_in;
            branch_out     <= branch_in;
            jal_out        <= jal_in;
            jalr_out       <= jalr_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            funct3_out     <= funct3_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
        // else: enable == 0 ? hold previous outputs (stall)
    end
endmodule

