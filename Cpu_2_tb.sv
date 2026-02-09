`timescale 1ns/1ps

module tb_processor;

  // --------------------------------------------------
  // Clock & Reset
  // --------------------------------------------------
  logic clk;
  logic reset;

  // Clock: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset
  initial begin
    reset = 1;
    #200;
    reset = 0;
  end

  // --------------------------------------------------
  // DUT
  // --------------------------------------------------
  cpu_top dut (
    .clk   (clk),
    .reset (reset)
  );

  // --------------------------------------------------
  // Instruction memory initialization
  // --------------------------------------------------
  initial begin
    $display("[TB] Loading instruction memory...");
    $readmemh("instr2_mem_init.hex", dut.IMEM.memory);
  end

  // --------------------------------------------------
  // Sanity check: ensure IMEM actually loaded
  // --------------------------------------------------
  initial begin
    #1;
    if (dut.IMEM.memory[0] === 32'h00000013) begin
      $fatal("IMEM not loaded: first instruction is NOP");
    end
  end

  // --------------------------------------------------
  // Optional: Write-back trace
  // --------------------------------------------------
  integer cycle;
  initial cycle = 0;

  always @(posedge clk) begin
    if (!reset) begin
      cycle <= cycle + 1;
      if (dut.wb_reg_write) begin
        $display("[WB] cycle=%0d  x%0d <= %h",
                 cycle, dut.wb_rd, dut.wb_data);
      end
    end
  end

  // --------------------------------------------------
  // FINAL SELF-CHECKING ASSERTIONS
  // --------------------------------------------------
  initial begin
    // Declarations must come first
    int r0, r1, r2, r3, r4, r5, r6, r7, r17;

    // Wait for reset to deassert
    @(negedge reset);

    // Wait long enough for pipeline to complete
    repeat (60) @(posedge clk);

    // Read architectural register file
    r0  = $signed(dut.RF.regs[0]);
    r1  = $signed(dut.RF.regs[1]);
    r2  = $signed(dut.RF.regs[2]);
    r3  = $signed(dut.RF.regs[3]);
    r4  = $signed(dut.RF.regs[4]);
    r5  = $signed(dut.RF.regs[5]);
    r6  = $signed(dut.RF.regs[6]);
    r7  = $signed(dut.RF.regs[7]);
    r17 = $signed(dut.RF.regs[17]);

    $display("====================================");
    $display("FINAL REGISTER STATE:");
    $display("x0=%0d x1=%0d x2=%0d x3=%0d", r0, r1, r2, r3);
    $display("x4=%0d x5=%0d x6=%0d x7=%0d", r4, r5, r6, r7);
    $display("x17=%0d", r17);
    $display("====================================");

    // Assertions
    if (r0  !== 0)   $fatal("FAIL: x0 must be 0");
    if (r1  !== 5)   $fatal("FAIL: x1 expected 5");
    if (r2  !== 10)  $fatal("FAIL: x2 expected 10");
    if (r3  !== 20)  $fatal("FAIL: x3 (SH1ADD) expected 20");
    if (r4  !== 30)  $fatal("FAIL: x4 (SH2ADD) expected 30");
    if (r5  !== 50)  $fatal("FAIL: x5 (SH3ADD) expected 50");
    if (r6  !== 50)  $fatal("FAIL: x6 (ADD) expected 50");
    if (r7  !== -20) $fatal("FAIL: x7 (SUB) expected -20");
    if (r17 !== 20)  $fatal("FAIL: x17 (LD) expected 20");

    $display("====================================");
    $display("ALL TESTS PASSED");
    $display("====================================");

    $finish;
  end

endmodule

