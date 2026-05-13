module pc #(parameter N = 16) (
	input clk,
	input rst,
	input pc_en,
	input jmp_en,
	input[N - 1:0] jmp_offset,
	output[N - 1:0] w
);
	wire[N - 1:0] cur_pc, next_pc, offset;
	assign offset = jmp_en ? jmp_offset : 1;
	d_ff #(.N(N)) pc_reg(.d(next_pc), .clk(clk), .rst(rst), .en(pc_en), .q(w));
	add #(.N(N)) rel_jump(.a(w), .b(offset), .x(next_pc), .cout(), .z(), .n(), .o());
endmodule
