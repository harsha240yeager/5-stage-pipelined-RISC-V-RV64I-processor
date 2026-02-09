// control_unit.sv - Main Control Unit
// Decodes instruction opcode/funct fields to generate control signals

import Shared_types::*;

module control_unit (
    input  logic [31:0] instr,

    output logic        alu_src,
    output alu_op_t     alu_ctrl,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic        mem_read,
    output logic        mem_write,
    output logic        reg_write,
    output logic [1:0]  mem_to_reg,
    output logic [2:0]  funct3_out
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    always_comb begin
        // ---------------- defaults ----------------
        alu_src    = 1'b0;
        alu_ctrl   = ALU_ADD;
        branch     = 1'b0;
        jal        = 1'b0;
        jalr       = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        reg_write  = 1'b0;
        mem_to_reg = 2'b00;
        funct3_out = funct3;

        unique case (opcode)

         // ================= R-type =================
7'b0110011: begin
    reg_write = 1'b1;
    alu_src   = 1'b0;   // R-type ALWAYS uses rs2

    case (funct3)
        3'b000: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
        3'b001: alu_ctrl = ALU_SLL;
        3'b010: alu_ctrl = ALU_SLT;
        3'b011: alu_ctrl = ALU_SLTU;
        3'b100: alu_ctrl = ALU_XOR;
        3'b101: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
        3'b110: alu_ctrl = ALU_OR;
        3'b111: alu_ctrl = ALU_AND;
    endcase

    // Zba override
    if (funct3 == 3'b000) begin
        case (funct7)
            7'b0010000: alu_ctrl = ALU_SH1ADD;
            7'b0010001: alu_ctrl = ALU_SH2ADD;
            7'b0010010: alu_ctrl = ALU_SH3ADD;
            default: ;
        endcase
    end
end



            // ================= I-type =================
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;

                case (funct3)
                    3'b000: alu_ctrl = ALU_ADD;   // ADDI
                    3'b010: alu_ctrl = ALU_SLT;
                    3'b011: alu_ctrl = ALU_SLTU;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b111: alu_ctrl = ALU_AND;
                    3'b001: alu_ctrl = ALU_SLL;
                    3'b101: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                endcase
            end

            // ================= RV64 *W =================
            7'b0111011: begin
                reg_write = 1'b1;

                case (funct3)
                    3'b000: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SUBW : ALU_ADDW;
                    3'b001: alu_ctrl = ALU_SLLW;
                    3'b101: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SRAW : ALU_SRLW;
                endcase
            end

            // ================= Branch =================
            7'b1100011: begin
                branch   = 1'b1;
                alu_ctrl = ALU_SUB;
            end

            // ================= JAL =================
            7'b1101111: begin
                jal        = 1'b1;
                reg_write  = 1'b1;
                mem_to_reg = 2'b10;
            end

            // ================= JALR =================
            7'b1100111: begin
                jalr       = 1'b1;
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_to_reg = 2'b10;
            end

            // ================= Loads =================
            7'b0000011: begin
                mem_read   = 1'b1;
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                alu_ctrl   = ALU_ADD;
                mem_to_reg = 2'b01;
            end

            // ================= Stores =================
            7'b0100011: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = ALU_ADD;
            end

            // ================= LUI =================
            7'b0110111: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = ALU_ADD;
            end

            // ================= AUIPC =================
            7'b0010111: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = ALU_ADD;
            end

            default: ;
        endcase
    end

endmodule

