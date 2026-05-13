module fsm_control #(parameter block = 3, parameter alu_modes = 4, parameter opcode_size = 16, parameter in_size = 4) (
	input clock,
	input rst, 
	input en, 
	input[opcode_size - 1:0] cur_instruction,
	input[3:0] state,
	output[block - 1:0] r_en, 
	output[block - 1:0] r_out,
	output a_en,
	output g_en,
	output g_out,
	output done,
	output[alu_modes - 1:0] alu_mode
);
	wire[3:0] next_state;
	fsm_next #(.op_size(opcode_size), .in_size(in_size)) next (
		.state(state),
		.cur_in(cur_instruction),
		.next_state(next_state)
	);
	fsm_state_reg store(
		.clock(clock),
		.rst(rst),
		.en(en),
		.next_state(next_state),
		.state(state)
	);
	fsm_output #(.in(block), .op_size(opcode_size), ) out(
		.cur_in(cur_instruction),
		.state(state),
		.r_en(r_en),
		.r_out(r_out),
		.a_en(a_en),
		.g_en(g_en),
		.g_out(g_out),
		.done(done),
		.alu_mode(alu_mode),
	);
endmodule