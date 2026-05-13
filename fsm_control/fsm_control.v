module fsm_control #(
	parameter block = 4,
	parameter alu_modes = 4,
	parameter opcode_size = 32,
	parameter in_size = 4,
	parameter N = 16
) (
	input clock,
	input rst,
	input en,
	input[opcode_size - 1:0] cur_instruction,
	input status,
	output[3:0] state,
	output[block:0] r_en,
	output[block:0] r_out,
	output a_en,
	output g_en,
	output g_out,
	output dmem_en,
	output dmem_out,
	output pmem_en,
	output imm_en,
	output opcode_en,
	output pc_en,
	output pc_out,
	output done,
	output[alu_modes - 1:0] alu_mode,
	output status_en,
	output status_out
);
	wire[3:0] next_state;
	fsm_next #(.op_size(opcode_size), .in_size(in_size)) next (
		.state(state),
		.status(status),
		.cur_in(cur_instruction),
		.next_state(next_state)
	);
	fsm_state_register store(
		.clock(clock),
		.rst(rst),
		.enable(en),
		.next_state(next_state),
		.state(state)
	);
	fsm_output #(.block(block), .op_size(opcode_size), .in_size(in_size), .alu_modes(alu_modes), .N(N)) out(
		.cur_in(cur_instruction),
		.status(status),
		.state(state),
		.r_en(r_en),
		.r_out(r_out),
		.a_en(a_en),
		.g_en(g_en),
		.g_out(g_out),
		.dmem_en(dmem_en),
		.dmem_out(dmem_out),
		.pmem_en(pmem_en),
		.imm_en(imm_en),
		.opcode_en(opcode_en),
		.pc_en(pc_en),
		.pc_out(pc_out),
		.done(done),
		.alu_mode(alu_mode),
		.status_en(status_en),
		.status_out(status_out)
	);
endmodule
