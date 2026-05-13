`timescale 1ns/1ps

// ============================================================
// Instruction format (32-bit):
//   [31:28]  4-bit opcode
//   [27:24]  unused
//   [23:8]   16-bit immediate  (LDI only)
//   [7:4]    Rx  destination   (MOV / ADD / SUB)
//   [3:0]    Ry  destination   (LDI) / source (MOV / ADD / SUB)
//
//   LDI Ry, imm   opcode = 0   Ry  = imm
//   MOV Rx, Ry    opcode = 1   Rx  = Ry
//   ADD Rx, Ry    opcode = 2   Rx  = Rx + Ry
//   SUB Rx, Ry    opcode = 4   Rx  = Rx - Ry
// ============================================================
//
// REQUIRED FIXES before simulating:
//   1. fsm_control.v: rename `fsm_state_reg` instantiation to
//      `fsm_state_register` (the actual module name in fsm_state_reg.v)
//   2. fsm_control.v: change `input[3:0] state` to `wire[3:0] state`
//   3. processor.v: implement the module with the port list below
// ============================================================

module tb_processor;
    localparam N = 16;

    reg          clk, rst, en;
    reg  [31:0]  instruction;
    wire         done;
    wire [N-1:0] bus;

    // Expected processor port list:
    //   processor #(.N(N)) dut (
    //       .clk(clk), .rst(rst), .en(en),
    //       .instruction(instruction),
    //       .done(done), .bus(bus)
    //   );
    processor #(.N(N)) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .instruction(instruction),
        .done(done),
        .bus(bus)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // --------------------------------------------------------
    // Execute one instruction; blocks until done goes high
    // --------------------------------------------------------
    task exec;
        input [31:0] instr;
        begin
            @(negedge clk);
            instruction = instr;
            en = 1;
            @(posedge clk);  // state 0 → 1
            #1;
            wait(!done);     // confirm FSM left idle
            wait(done);      // wait for completion (state → 0)
            @(negedge clk);
            en = 0;
        end
    endtask

    // --------------------------------------------------------
    // Instruction builders
    // --------------------------------------------------------
    function [31:0] ldi;
        input [3:0]  ry;
        input [15:0] imm;
        ldi = {4'd0, 4'd0, imm, 4'd0, ry};
    endfunction

    function [31:0] mov;
        input [3:0] rx, ry;
        mov = {4'd1, 4'd0, 16'd0, rx, ry};
    endfunction

    function [31:0] add;
        input [3:0] rx, ry;
        add = {4'd2, 4'd0, 16'd0, rx, ry};
    endfunction

    function [31:0] sub;
        input [3:0] rx, ry;
        sub = {4'd4, 4'd0, 16'd0, rx, ry};
    endfunction

    // --------------------------------------------------------
    // Test sequence
    // --------------------------------------------------------
    initial begin
        $dumpfile("tb_processor.vcd");
        $dumpvars(0, tb_processor);

        rst = 1; en = 0; instruction = 32'b0;
        repeat(4) @(posedge clk);
        rst = 0;
        @(posedge clk);

        $display("=== Processor test begin ===");

        // --- LDI: load immediates into three registers ---
        exec(ldi(4'd0, 16'd10));
        $display("[%0t] LDI R0, 10  ->  R0 = 10", $time);

        exec(ldi(4'd1, 16'd5));
        $display("[%0t] LDI R1, 5   ->  R1 = 5", $time);

        exec(ldi(4'd2, 16'd3));
        $display("[%0t] LDI R2, 3   ->  R2 = 3", $time);

        // --- MOV: copy R0 into R3 ---
        exec(mov(4'd3, 4'd0));
        $display("[%0t] MOV R3, R0  ->  R3 = 10", $time);

        // --- ADD ---
        exec(add(4'd0, 4'd1));   // R0 = 10 + 5 = 15
        $display("[%0t] ADD R0, R1  ->  R0 = 15", $time);

        exec(add(4'd1, 4'd2));   // R1 = 5 + 3 = 8
        $display("[%0t] ADD R1, R2  ->  R1 = 8", $time);

        // --- SUB ---
        exec(sub(4'd0, 4'd2));   // R0 = 15 - 3 = 12
        $display("[%0t] SUB R0, R2  ->  R0 = 12", $time);

        exec(sub(4'd0, 4'd3));   // R0 = 12 - 10 = 2
        $display("[%0t] SUB R0, R3  ->  R0 = 2", $time);

        $display("=== Test complete ===");
        $finish;
    end

    // Print bus value whenever it changes during execution
    always @(bus) begin
        if (!rst && !done)
            $display("[%0t]   bus = %0d (0x%04h)", $time, bus, bus);
    end

endmodule
