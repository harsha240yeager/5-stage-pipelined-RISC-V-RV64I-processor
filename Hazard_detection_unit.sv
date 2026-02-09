// hazard_detection_unit.sv
// Simple hazard detection: detect load-use hazard and request a stall.
//
// Interface notes:
// - If a load is in EX (ex_mem_read==1) and EX.rd matches ID.rs1 or ID.rs2,
//   we must stall the pipeline for one cycle: freeze IF/ID and PC, and
//   prevent ID/EX from updating (ID/EX enable will be deasserted by cpu_top).
// - Branch handling (flush) is kept separate: branch_taken is an input but
//   we don't flush ID/EX here (branch logic in cpu_top will assert flush).
//
// Signals used in your cpu_top:
// .if_id_write  -> when 0, IF/ID should be frozen
// .pc_write     -> when 0, PC should be frozen
// .id_ex_flush  -> optional (we keep 0 for load-use stalls)
module hazard_detection_unit (
    input  logic [4:0] rs1_id,
    input  logic [4:0] rs2_id,
    input  logic       ex_mem_read,   // true when EX stage is performing a load
    input  logic [4:0] ex_rd_idx,     // destination reg index in EX stage
    input  logic       branch_taken,  // supplied by cpu_top (for advanced uses)

    output logic       stall,         // true when stall requested (debug)
    output logic       if_id_write,   // when 0, IF/ID should NOT advance (freeze)
    output logic       pc_write,      // when 0, PC should NOT advance (freeze)
    output logic       id_ex_flush    // when 1, ID/EX should be flushed (NOP injected)
);

    always_comb begin
        // defaults: no stall, allow writes
        stall        = 1'b0;
        if_id_write  = 1'b1;
        pc_write     = 1'b1;
        id_ex_flush  = 1'b0;

        // ---- Load-use hazard detection ----
        // If EX stage is a load and EX.rd matches either ID.rs1 or ID.rs2,
        // we must stall the pipeline for one cycle (classic textbook case).
        if (ex_mem_read && (ex_rd_idx != 5'd0) &&
            ((ex_rd_idx == rs1_id) || (ex_rd_idx == rs2_id))) begin
            stall       = 1'b1;
            if_id_write = 1'b0; // freeze IF/ID
            pc_write    = 1'b0; // freeze PC
            id_ex_flush = 1'b0; // do NOT flush ID/EX ? hold it (enable logic does that)
        end

        // ---- Branch handling note ----
        // We do not assert id_ex_flush here for branches because cpu_top already
        // handles branch flush (branch_taken -> flush). Keeping flush logic
        // in cpu_top keeps responsibilities clear.
    end

endmodule


