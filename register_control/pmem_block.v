module pmem_block #(
    parameter imm_l = 16,
    parameter opcode_size = 32,
    parameter mem_len = 1 << imm_l
) (
    input [imm_l - 1:0] addr,
    output [opcode_size - 1:0] w
);
    reg[opcode_size - 1:0] mem[0:mem_len - 1];
    initial begin
        $readmemb("program.hex", mem);
		$display("mem[%b] --> %b", 8'd0, mem[8'd0]);
    end
	always @(addr) begin
		$display("mem[%b] --> %b", addr, mem[addr]);
	end
    assign w = mem[addr];
endmodule
