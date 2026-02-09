// ============================================================
// cpu_top.sv
// 5-stage RV64I + Zba pipelined processor
// IF ? ID ? EX ? MEM ? WB
// ============================================================

import Shared_types::*;

module cpu_top (
    input logic clk,
    input logic  reset
);

    // =========================================================
    // IF STAGE
    // =========================================================
    logic [63:0] pc_current, pc_next;
    logic        pc_enable;

    pc PC (
        .clk     (clk),
        .reset   (reset),
        .enable  (pc_enable),
        .next_pc (pc_next),
        .pc_out  (pc_current)
    );

    logic [31:0] instr_f;
    imem IMEM (
        .addr  (pc_current),
        .instr (instr_f)
    );

    // =========================================================
    // IF / ID PIPELINE REGISTER
    // =========================================================
    logic [63:0] pc_id;
    logic [31:0] instr_id;
    logic        if_id_enable, if_id_flush;

    if_id IF_ID (
        .clk       (clk),
        .reset     (reset),
        .enable    (if_id_enable),
        .flush     (if_id_flush),
        .pc_in     (pc_current),
        .instr_in  (instr_f),
        .pc_out    (pc_id),
        .instr_out (instr_id)
    );

    // =========================================================
    // ID STA
    // =========================================================
    logic [4:0] rs1_id, rs2_id, rd_id;
    assign rs1_id = instr_id[19:15];
    assign rs2_id = instr_id[24:20];
    assign rd_id  = instr_id[11:7];

    // Raw RF outputs and bypassed versions
    logic [63:0] rs1_val_id_raw, rs2_val_id_raw;
    logic [63:0] rs1_val_id_byp, rs2_val_id_byp;

    // imm and control outputs remain the same
    logic [63:0] imm_id;
    imm_gen IMMGEN (.instr(instr_id), .imm(imm_id));

    logic        alu_src_id, branch_id, jal_id, jalr_id;
    logic        mem_read_id, mem_write_id, reg_write_id;
    logic [1:0]  mem_to_reg_id;
    alu_op_t alu_ctrl_id;
    logic [2:0]  funct3_id;

    control_unit CTRL (
        .instr       (instr_id),
        .alu_src     (alu_src_id),
        .alu_ctrl    (alu_ctrl_id),
        .branch      (branch_id),
        .jal         (jal_id),
        .jalr        (jalr_id),
        .mem_read    (mem_read_id),
        .mem_write   (mem_write_id),
        .reg_write   (reg_write_id),
        .mem_to_reg  (mem_to_reg_id),
        .funct3_out  (funct3_id)
    );

    // Register file
    logic [63:0] wb_data;
    logic [4:0]  wb_rd;
    logic        wb_reg_write;

    register_file RF (
        .clk        (clk),
        .rs1_idx    (rs1_id),
        .rs2_idx    (rs2_id),
        .rd_idx     (wb_rd),
        .rd_data    (wb_data),
        .reg_write  (wb_reg_write),
        .rs1_data   (rs1_val_id_raw),
        .rs2_data   (rs2_val_id_raw)
    );
   

    // =========================================================
    // ID / EX PIPELINE REGISTER
    // =========================================================
    logic [63:0] pc_ex, pc4_ex;
    logic [63:0] rs1_ex, rs2_ex, imm_ex;
    logic [4:0]  rs1_ex_idx, rs2_ex_idx, rd_ex;
    logic        alu_src_ex, branch_ex, jal_ex, jalr_ex;
    logic        mem_read_ex, mem_write_ex, reg_write_ex;
    logic [1:0]  mem_to_reg_ex;
    alu_op_t alu_ctrl_ex;
    logic [2:0]  funct3_ex;
    logic        id_ex_flush;
    logic pc_write, if_id_write;

   id_ex ID_EX (
        .clk            (clk),
        .reset          (reset),
        .flush          (id_ex_flush),
        .enable         (if_id_write),    // <--- use hazard signal to freeze ID/EX
        .pc_in          (pc_id),
        .pc_plus4_in    (pc_id + 64'd4),
        .rs1_val_in     (rs1_val_id_byp),
        .rs2_val_in     (rs2_val_id_byp),
        .imm_in         (imm_id),
        .rs1_idx_in     (rs1_id),
        .rs2_idx_in     (rs2_id),
        .rd_idx_in      (rd_id),
        .alu_ctrl_in    (alu_ctrl_id),
        .alu_src_in     (alu_src_id),
        .branch_in      (branch_id),
        .jal_in         (jal_id),
        .jalr_in        (jalr_id),
        .mem_read_in    (mem_read_id),
        .mem_write_in   (mem_write_id),
        .funct3_in      (funct3_id),
        .reg_write_in   (reg_write_id),
        .mem_to_reg_in  (mem_to_reg_id),

        .pc_out          (pc_ex),
        .pc_plus4_out    (pc4_ex),
        .rs1_val_out     (rs1_ex),
        .rs2_val_out     (rs2_ex),
        .imm_out         (imm_ex),
        .rs1_idx_out     (rs1_ex_idx),
        .rs2_idx_out     (rs2_ex_idx),
        .rd_idx_out      (rd_ex),//C:/Modelsim_projects/ID_EX_pipeline_registers.sv
        .alu_ctrl_out    (alu_ctrl_ex),
        .alu_src_out     (alu_src_ex),
        .branch_out      (branch_ex),
        .jal_out         (jal_ex),
        .jalr_out        (jalr_ex),
        .mem_read_out    (mem_read_ex),
        .mem_write_out   (mem_write_ex),
        .funct3_out      (funct3_ex),
        .reg_write_out   (reg_write_ex),
        .mem_to_reg_out  (mem_to_reg_ex)
    );

    // =========================================================
    // EX STAGE (FORWARDING + ALU)
    // =========================================================
    logic [1:0] forwardA, forwardB;

    logic [63:0] alu_result_mem;
    logic [4:0]  rd_mem;
    logic        reg_write_mem;

    forwarding_unit FWD (
        .rs1_ex        (rs1_ex_idx),
        .rs2_ex        (rs2_ex_idx),
        .rd_mem        (rd_mem),
        .reg_write_mem (reg_write_mem),
        .rd_wb         (wb_rd),
        .reg_write_wb  (wb_reg_write),
        .forward_a     (forwardA),
        .forward_b     (forwardB)
    );

    logic [63:0] alu_op1, alu_op2;

    always_comb begin
        case (forwardA)
            2'b10: alu_op1 = alu_result_mem;
            2'b01: alu_op1 = wb_data;
            default: alu_op1 = rs1_ex;
        endcase

        case (forwardB)
            2'b10: alu_op2 = alu_result_mem;
            2'b01: alu_op2 = wb_data;
            default: alu_op2 = rs2_ex;
        endcase
    end

    logic [63:0] alu_in2;
  assign alu_in2 = alu_src_ex ? imm_ex : alu_op2;


    logic [63:0] alu_result_ex;

    alu ALU (
        .op1      (alu_op1),
        .op2      (alu_in2),
        .alu_ctrl (alu_ctrl_ex),
        .result   (alu_result_ex)
    );

    // =========================================================
    // STORE DATA FORWARDING (FINAL FIX)
    // =========================================================
  // =========================================================
// STORE DATA FORWARDING (use same forwarded ALU operand B)
logic [63:0] store_data_ex;

// Use the same computed ALU operand (alu_op2) for store data so
// forwarding behavior is identical and cannot conflict.
assign store_data_ex = alu_op2;

    // =========================================================
    // BRANCH / JUMP LOGIC
    // =========================================================
    logic branch_taken;
    logic [63:0] branch_target;

    always_comb begin
        branch_taken  = 1'b0;
        branch_target = 64'b0;

        if (branch_ex) begin
            case (funct3_ex)
                3'b000: branch_taken = (alu_op1 == alu_op2); // BEQ
                3'b001: branch_taken = (alu_op1 != alu_op2); // BNE
                3'b100: branch_taken = ($signed(alu_op1) < $signed(alu_op2));
                3'b101: branch_taken = ($signed(alu_op1) >= $signed(alu_op2));
                3'b110: branch_taken = (alu_op1 < alu_op2);
                3'b111: branch_taken = (alu_op1 >= alu_op2);
            endcase
            if (branch_taken)
                branch_target = pc_ex + imm_ex;
        end

        if (jal_ex) begin
            branch_taken  = 1'b1;
            branch_target = pc_ex + imm_ex;
        end

        if (jalr_ex) begin
            branch_taken  = 1'b1;
            branch_target = (alu_op1 + imm_ex) & ~64'd1;
        end
    end

    // =========================================================
    // EX / MEM PIPELINE REGISTER
    // =========================================================
    logic [63:0] rs2_mem, pc4_mem;
    logic        mem_read_mem, mem_write_mem;
    logic [2:0]  funct3_mem;
    logic [1:0]  mem_to_reg_mem;

    ex_mem EX_MEM (
        .clk            (clk),
        .reset          (reset),
        .alu_result_in  (alu_result_ex),
        .rs2_val_in     (store_data_ex),
        .rd_idx_in      (rd_ex),
        .reg_write_in   (reg_write_ex),
        .mem_read_in    (mem_read_ex),
        .mem_write_in   (mem_write_ex),
        .funct3_in      (funct3_ex),
        .mem_to_reg_in  (mem_to_reg_ex),
        .pc_plus4_in    (pc4_ex),

        .alu_result_out (alu_result_mem),
        .rs2_val_out    (rs2_mem),
        .rd_idx_out     (rd_mem),
        .reg_write_out  (reg_write_mem),
        .mem_read_out   (mem_read_mem),
        .mem_write_out  (mem_write_mem),
        .funct3_out     (funct3_mem),
        .mem_to_reg_out (mem_to_reg_mem),
        .pc_plus4_out   (pc4_mem)
    );
     always_comb begin
        // default: values come from RF
        rs1_val_id_byp = rs1_val_id_raw;
        rs2_val_id_byp = rs2_val_id_raw;

        // EX/MEM bypass ? highest priority
        if (reg_write_mem && (rd_mem != 5'd0)) begin
            if (rd_mem == rs1_id)
                rs1_val_id_byp = alu_result_mem;
            if (rd_mem == rs2_id)
                rs2_val_id_byp = alu_result_mem;
        end

        // MEM/WB bypass ? lower priority
        if (wb_reg_write && (wb_rd != 5'd0)) begin
            if (wb_rd == rs1_id)
                rs1_val_id_byp = wb_data;
            if (wb_rd == rs2_id)
                rs2_val_id_byp = wb_data;
        end
    end

    // =========================================================
    // MEM STAGE
    // =========================================================
    logic [63:0] mem_data;

    dmem DMEM (
        .clk       (clk),
        .addr      (alu_result_mem),
        .wdata     (rs2_mem),
        .mem_read  (mem_read_mem),
        .mem_write (mem_write_mem),
        .funct3    (funct3_mem),
        .rdata     (mem_data)
    );

    // =========================================================
    // MEM / WB PIPELINE REGISTER
    // =========================================================
    logic [63:0] alu_wb, mem_wb, pc4_wb;
    logic [1:0]  mem_to_reg_wb;

    mem_wb MEM_WB (
        .clk            (clk),
        .reset          (reset),
        .alu_result_in  (alu_result_mem),
        .mem_data_in    (mem_data),
        .rd_idx_in      (rd_mem),
        .reg_write_in   (reg_write_mem),
        .mem_to_reg_in  (mem_to_reg_mem),
        .pc_plus4_in    (pc4_mem),

        .alu_result_out (alu_wb),
        .mem_data_out   (mem_wb),
        .rd_idx_out     (wb_rd),
        .reg_write_out  (wb_reg_write),
        .mem_to_reg_out (mem_to_reg_wb),
        .pc_plus4_out   (pc4_wb)
    );

    // =========================================================
    // WB STAGE
    // =========================================================
    always_comb begin
        case (mem_to_reg_wb)
            2'b00: wb_data = alu_wb;
            2'b01: wb_data = mem_wb;
            2'b10: wb_data = pc4_wb;
            default: wb_data = alu_wb;
        endcase
    end

    // =========================================================
    // HAZARD DETECTION
    // =========================================================
    
    logic id_ex_flush_hazard;


    hazard_detection_unit HAZARD (
        .rs1_id       (rs1_id),
        .rs2_id       (rs2_id),
        .ex_mem_read  (mem_read_ex),
        .ex_rd_idx    (rd_ex),
        .branch_taken (branch_taken),
        .stall        (),
        .if_id_write  (if_id_write),
        .pc_write     (pc_write),
        .id_ex_flush  (id_ex_flush_hazard)
    );

    //assign pc_enable    = reset ? 1'b1 : pc_write;4
    // TEMPORARY: force PC to run for bring-up/debug
    // assign pc_enable = 1'b1;
  /*  assign pc_enable = reset ? 1'b1 :
                   (pc_write === 1'b1);
   // assign if_id_enable = if_id_write;
    assign if_id_enable = reset ? 1'b1 :
                      (if_id_write === 1'b1);*/



    logic branch_taken_d;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            branch_taken_d <= 1'b0;
        else
            branch_taken_d <= branch_taken;
    end

    assign pc_enable =
        reset ? 1'b1 :
        (pc_write | branch_taken);

     assign if_id_enable = reset ? 1'b1 : if_id_write;



   assign if_id_flush = branch_taken;

    assign id_ex_flush = id_ex_flush_hazard | branch_taken;
    //assign id_ex_flush = branch_taken;
    assign pc_next      = branch_taken ? branch_target : (pc_current + 64'd4);

endmodule

