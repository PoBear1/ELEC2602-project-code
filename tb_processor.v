`timescale 1ns/1ps

// ============================================================
// 32-bit instruction encoding
//
//   [31:28]  4-bit opcode
//   [27:24]  unused
//   [23:20]  Rx  – destination register  (MOV / ADD / SUB)
//   [19:16]  Rd  – destination register  (LDI)
//            Ry  – source register       (MOV / ADD / SUB)
//   [15:0]   16-bit immediate            (LDI only)
//
//   Opcode  Mnemonic       Operation
//   ------  -------------- --------------------
//      1    LDI  Rd, imm   Rd = imm
//      2    MOV  Rx, Ry    Rx = Ry
//      3    ADD  Rx, Ry    Rx = Rx + Ry
//      5    SUB  Rx, Ry    Rx = Rx - Ry
// ============================================================

module tb_processor;

    reg clk, rst;

    processor dut (
        .clock(clk),
        .reset(rst)
    );

    initial clk = 0;
    always #5 clk = ~clk;   // 10 ns period, 100 MHz

    // ---- Instruction constructors ----

    function [31:0] ldi;
        input [3:0]  rd;
        input [7:0] imm;
        ldi = {8'd1, 4'd0, rd, imm};
    endfunction

    function [31:0] mov;
        input [3:0] rx, ry;
        mov = {8'd2, rx, ry, 8'd0};
    endfunction

    function [31:0] add;
        input [3:0] rx, ry;
        add = {8'd3, rx, ry, 8'd0};
    endfunction

    function [31:0] sub;
        input [3:0] rx, ry;
        sub = {8'd5, rx, ry, 8'd0};
    endfunction

    // ---- Test program ----
    //
    //  Addr  Instruction           Expected state after execution
    //  ----  --------------------  ------------------------------
    //   0    LDI R0, 10            R0 = 10
    //   1    LDI R1,  5            R1 = 5
    //   2    LDI R2,  3            R2 = 3
    //   3    MOV R3, R0            R3 = 10
    //   4    ADD R0, R1            R0 = 10 + 5  = 15
    //   5    ADD R1, R2            R1 =  5 + 3  =  8
    //   6    SUB R0, R2            R0 = 15 - 3  = 12
    //   7    SUB R0, R3            R0 = 12 - 10 =  2
    //   8    (halt – undefined opcode keeps FSM idle)

    initial begin
        $dumpfile("tb_processor.vcd");
        // Dump selected hierarchy to keep VCD manageable
        $dumpvars(0, tb_processor);   // top-level signals

        rst = 1;

        // Load program into pmem after $readmemh has initialised it.
        // All other initial blocks start at time 0; #1 ensures ordering.
        #1;
        // dut.pmem.mem[0] = ldi(4'd0, 8'd10);
        // dut.pmem.mem[1] = ldi(4'd1, 8'd5);
        // dut.pmem.mem[2] = ldi(4'd2, 8'd3);
        // dut.pmem.mem[3] = mov(4'd3, 4'd0);
        // dut.pmem.mem[4] = add(4'd0, 4'd1);
        // dut.pmem.mem[5] = add(4'd1, 4'd2);
        // dut.pmem.mem[6] = sub(4'd0, 4'd2);
        // dut.pmem.mem[7] = sub(4'd0, 4'd3);
        // dut.pmem.mem[8] = 32'hFFFF_FFFF;   // undefined opcode → FSM stays idle

        repeat(4) @(posedge clk);
        rst = 0;

        $display("=== Processor simulation start ===");

        // Each instruction: LDI=1 FSM state, MOV=1, ADD=3, SUB=4.
        // 8 instructions × worst-case 4 states + overhead = ~50 cycles.
        repeat(80) @(posedge clk);

        $display("=== Simulation complete ===");
        $finish;
    end

    // ---- Monitors ----

    // Show every bus change during active execution
    always @(dut.data_bus) begin
        if (!rst && dut.data_bus !== {16{1'bz}})
            $display("[%0t]   bus = %0d (0x%04h)", $time, dut.data_bus, dut.data_bus);
    end

    // Announce start of each instruction; at negedge done the PC has not yet incremented
    always @(negedge dut.done) begin
        if (!rst)
            $display("[%0t] -- executing PC=%0d : 0x%08h",
                     $time, dut.pc_addr, dut.pmem.mem[dut.pc_addr]);
    end

    // Announce completion; at posedge done the PC has already incremented
    always @(posedge dut.done) begin
        if (!rst)
            $display("[%0t] -- done  (was PC=%0d, next PC=%0d)",
                     $time, dut.pc_addr - 1, dut.pc_addr);
    end

endmodule
