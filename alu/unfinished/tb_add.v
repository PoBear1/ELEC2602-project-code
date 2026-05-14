`timescale 1ns/1ps
module tb_add;
    parameter N = 8;

    reg [N-1:0] a, b;
    wire [N-1:0] x;
    wire cout, z, n, o;

    add #(.N(N)) dut (.a(a), .b(b), .x(x), .cout(cout), .z(z), .n(n), .o(o));

    integer pass, fail;

    task check;
        input [N-1:0] exp_x;
        input exp_cout, exp_z, exp_n, exp_o;
        input [63:0] test_id;
        begin
            #1;
            if (x === exp_x && cout === exp_cout && z === exp_z && n === exp_n && o === exp_o) begin
                pass = pass + 1;
            end else begin
                fail = fail + 1;
                $display("FAIL test %0d: a=%0d b=%0d | got x=%0d cout=%b z=%b n=%b o=%b | exp x=%0d cout=%b z=%b n=%b o=%b",
                    test_id, a, b, x, cout, z, n, o, exp_x, exp_cout, exp_z, exp_n, exp_o);
            end
        end
    endtask

    initial begin
        pass = 0; fail = 0;

        // --- Basic addition ---
        a=0;   b=0;   check(0,   0, 1, 0, 0, 1);  // 0+0=0, zero flag
        a=1;   b=0;   check(1,   0, 0, 0, 0, 2);
        a=0;   b=1;   check(1,   0, 0, 0, 0, 3);
        a=3;   b=5;   check(8,   0, 0, 0, 0, 4);
        a=14;  b=16;  check(30,  0, 0, 0, 0, 5);   // from code.txt: LDI values

        // --- Unsigned carry-out ---
        a=8'hFF; b=1;    check(0,    1, 1, 0, 0, 6);   // 255+1=256 → x=0
        a=8'hFF; b=8'hFF; check(8'hFE, 1, 0, 1, 0, 7); // 255+255=510 → x=254
        a=8'h80; b=8'h80; check(0,    1, 1, 0, 1, 8);  // -128+(-128)=-256 → x=0, overflow

        // --- Zero flag ---
        a=0;   b=0;   check(0,   0, 1, 0, 0, 9);    // already covered, confirm z=1
        a=8'hFF; b=1; check(0,   1, 1, 0, 0, 10);   // zero with cout

        // --- Negative flag (MSB=1) ---
        a=200; b=0;   check(200, 0, 0, 1, 0, 11);   // 0xC8, MSB=1
        a=127; b=1;   check(128, 0, 0, 1, 1, 12);   // +127+1=+128 (0x80), neg+overflow

        // --- Signed overflow ---
        // pos + pos = neg
        a=8'd127; b=8'd1;   check(8'd128, 0, 0, 1, 1, 13);  // +127+1 → -128
        a=8'd64;  b=8'd64;  check(8'd128, 0, 0, 1, 1, 14);  // +64+64 → -128
        // neg + neg = pos
        a=8'h80; b=8'hFF; check(8'h7F, 1, 0, 0, 1, 15);    // -128+(-1) → +127
        a=8'hC0; b=8'hC1; check(8'h81, 1, 0, 1, 0, 16);    // -64+(-63) → -127, no overflow
        // no overflow cases
        a=8'hFF; b=8'h01; check(0,    1, 1, 0, 0, 17);     // -1+1=0
        a=64;    b=63;    check(127,  0, 0, 0, 0, 18);     // +64+63=+127, max pos, no overflow
        a=8'hC0; b=8'hC0; check(8'h80, 1, 0, 1, 0, 19);   // -64+(-64)=-128, exact, no overflow

        $display("Results: %0d passed, %0d failed", pass, fail);
        $finish;
    end
endmodule
