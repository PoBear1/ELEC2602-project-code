module fsm_control #(parameter N_regs = 16) (
	input clock,
	input rst, 
	input en, 
	input[15:0] cur_instruction,
	input[3:0] state,
	output[N_regs:0] r_en, 
	output[N_regs:0] r_out,
	output a_en,
	output g_en,
	output g_out,
	output done,
	output[3:0] alu_mode
);
	wire[3:0] next_state;
	fsm_next next(
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
	fsm_output #(.N_regs(N_regs)) out(
		.cur_in(cur_in),
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