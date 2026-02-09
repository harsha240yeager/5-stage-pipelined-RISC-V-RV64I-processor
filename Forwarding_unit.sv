module forwarding_unit (
    input  logic [4:0] rs1_ex,
    input  logic [4:0] rs2_ex,
    input  logic [4:0] rd_mem,
    input  logic       reg_write_mem,
    input  logic [4:0] rd_wb,
    input  logic       reg_write_wb,
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin
    // defaults
    forward_a = 2'b00;
    forward_b = 2'b00;

    // ---------- EX/MEM forwarding ----------
    if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs1_ex))
        forward_a = 2'b10;

    if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs2_ex))
        forward_b = 2'b10;

    // ---------- MEM/WB forwarding ----------
    if (reg_write_wb && (rd_wb != 0) &&
        !(reg_write_mem && (rd_mem != 0) && (rd_mem == rs1_ex)) &&
        (rd_wb == rs1_ex))
        forward_a = 2'b01;

    if (reg_write_wb && (rd_wb != 0) &&
        !(reg_write_mem && (rd_mem != 0) && (rd_mem == rs2_ex)) &&
        (rd_wb == rs2_ex))
        forward_b = 2'b01;
end
endmodule


