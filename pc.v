module pc #(parameter N = 16) (
	input clk,
	input rst,
	input pc_en,
	input pc_out,
	input jmp_en,
	input[N - 1:0] jmp_offset,
	output[N - 1:0] w
);
	wire[N - 1:0] cur_pc, next_pc, offset;
	assign offset = jmp_en ? jmp_offset : 1;
	d_ff #(.N(N)) pc_reg(.d(next_pc), .clk(clk), .rst(rst), .en(pc_en), .q(pc_val));
	add #(.N(N)) rel_jump(.a(cur_pc), .b(offset), .c(0), .x(next_pc), .cout(), .z(), .n(), .o());
	tri_buf #(.N(N)) buffer(.a(cur_pc), .en(pc_out), .b(w));
endmodule
