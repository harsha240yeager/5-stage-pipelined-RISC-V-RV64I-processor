// imm_gen.sv - Immediate Generator
// Generates a 64-bit immediate value from the 32-bit instruction, according to instruction format.
module imm_gen (
    input  logic [31:0] instr,
    output logic [63:0] imm
);
    logic [6:0] opcode;
    assign opcode = instr[6:0];
    always_comb begin
        unique case (opcode)
            7'b0010011,    // I-type (e.g., ALU immediate instructions like ADDI, ORI, etc.)
            7'b0000011,    // I-type (loads)
            7'b1100111: begin // JALR (also I-type format immediate)
                // 12-bit signed immediate [31:20] in instr
                imm = $signed(instr[31:20]);
            end
            7'b1101111: begin // J-type (JAL)
                // 20-bit signed immediate, bits: [31] imm[20], [19:12] imm[19:12], [20] imm[11], [30:21] imm[10:1], imm[0]=0
                logic [20:0] imm20;
                imm20[20]    = instr[31];            // bit 20 (sign)
                imm20[10:1]  = instr[30:21];         // bits 10:1
                imm20[11]    = instr[20];            // bit 11
                imm20[19:12] = instr[19:12];         // bits 19:12
                imm20[0]     = 1'b0;                 // lowest bit is 0 (J immediates are multiples of 2)
                imm = $signed(imm20);
            end
            7'b1100011: begin // B-type (branches)
                // 13-bit signed immediate from bits [31], [7], [30:25], [11:8], with lowest bit 0
                logic [12:0] imm13;
                imm13[12]   = instr[31];           // bit 12 (sign)
                imm13[10:5] = instr[30:25];        // bits 10:5
                imm13[4:1]  = instr[11:8];         // bits 4:1
                imm13[11]   = instr[7];            // bit 11
                imm13[0]    = 1'b0;                // lowest bit is 0 (branches are 2-byte aligned)
                imm = $signed(imm13);
            end
            7'b0100011: begin // S-type (stores)
                // 12-bit signed immediate from bits [31:25] and [11:7]
                logic [11:0] imm12;
                imm12[11:5] = instr[31:25];
                imm12[4:0]  = instr[11:7];
                imm = $signed(imm12);
            end
            7'b0110111,
            7'b0010111: begin // U-type (LUI/AUIPC)
                // 20-bit immediate in bits [31:12], bottom 12 bits are zero
                imm = $signed(instr[31:12] << 12);
            end
            default: begin
                imm = 64'b0;
            end
        endcase
    end
endmodule

