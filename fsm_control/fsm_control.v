module fsm_control #(
	parameter block = 4,
	parameter alu_modes = 4,
	parameter opcode_size = 16,
	parameter in_size = 8,
	parameter N = 16,
	parameter imm_l = 16,
	parameter state_s = 4
) (
	input clock,
	input rst,
	input en,
	input[opcode_size - 1:0] cur_instruction,
	input[3:0] status,
	output[state_s - 1:0] state,
	output[block:0] r_en,
	output[block:0] r_out,
	output a_en,
	output g_en,
	output g_out,
	output dmem_en,
	output dmem_out,
	output pc_en,
	output jmp_en,
	output[alu_modes - 1:0] alu_mode,
	output status_en,
	output status_out,
	output dmem_bus_sel,
	output imm_data_en,
	output done
);
	wire[3:0] next_state;
	fsm_next #(.op_size(opcode_size), .in_size(in_size), .state_s(state_s)) next (
		.state(state),
		.status(status),
		.cur_in(cur_instruction),
		.next_state(next_state)
	);
	fsm_state_register #(.state_s(state_s)) store(
		.clock(clock),
		.rst(rst),
		.enable(en),
		.next_state(next_state),
		.state(state)
	);
	fsm_output #(
		.block(block), 
		.op_size(opcode_size), 
		.in_size(in_size), 
		.alu_modes(alu_modes), 
		.N(N), .imm_l(imm_l), 
		.state_s(state_s)
	) out(
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
		.pc_en(pc_en),
		.jmp_en(jmp_en),
		.alu_mode(alu_mode),
		.status_en(status_en),
		.status_out(status_out),
		.dmem_bus_sel(dmem_bus_sel),
		.imm_data_en(imm_data_en),
		.done(done)
	);
endmodule
