module processor #(
	parameter block = 4,
	parameter num_regs = 16, 
	parameter alu_modes = 4,
	parameter opcode_size = 32,
	parameter in_size = 4,
	parameter N = 16
) (
	input clock,
	input reset
);
	wire[N - 1:0] data_bus;
	wire[opcode_size/2 - 1:0] opcode, imm; 
	wire[block - 1:0] dmem_addr, pc_addr;
	wire fsm_en;
	wire[opcode_size - 1:0] cur_instruction;
	wire[3:0] fsm_state;
	wire[block - 1:0] r_en, r_out;
	wire a_en;
	wire g_en, g_out;
	wire dmem_en, dmem_out;
	wire pmem_en, imm_en, opcode_en;
	wire reg_tri, reg_en, reg_num_tri, reg_num_en;
	wire pc_en, pc_out, jmp_en;
	wire[opcode_size - 1:0] pc_val, jmp_offset;
	wire[alu_modes - 1:0] alu_mode;
	wire status_en, status_out;
	wire dmem_bus_sel;
	wire done;

	// dmem
	reg_block #(
		.n(block),
		.regs(num_regs),
		.N(N)
	) dmem(
		.d(data_bus),
		.clk(clock),
		.reg_tri({dmem_out, dmem_addr}),
		.reg_en({dmem_en, dmem_addr}),
		.reg_rst(reset),
		.w(data_bus)
	);

	// pmem
	reg_block #(
		.n(block),
		.regs(num_regs),
		.N(opcode_size)
	) pmem(
		.d(0),
		.clk(clock),
		.reg_tri({pmem_en, pc_addr}),
		.reg_en(0),
		.reg_rst(reset),
		.w(cur_instruction)
	);

	// opcode/imm reg
	assign opcode = cur_instruction[opcode_size - 1:opcode_size/2]; 
	assign imm = cur_instruction[opcode_size/2 - 1:0];

	// demux imm to either bus or dmem
	demux #(.N(N)) demuxer()

	// program counter
	pc #(
		.N(opcode_size)
	) pc_reg (
		.clk(clock),
		.rst(reset),
		.pc_en(pc_en),
		.pc_out(pc_out),
		.jmp_en(jmp_en),
		.jmp_offset(data_bus),
		.w(pc_val)
	);

	// 
	reg_block #(
		.n(block),
		.regs(num_regs),
		.N(N)
	) registers (
		.d(data_bus),
		.clk(clock),
		.reg_tri({})
	);

	fsm_control #(
		.block(block),
		.alu_modes(alu_modes),
		.opcode_size(opcode_size),
		.in_size(in_size),
		.N(N)
	) controller(
		.clock(clock),
		.rst(reset),
		.en(fsm_en),
		.cur_instruction(opcode),
		.state(fsm_state),
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
		.alu_mode(alu_mode),
		.status_en(status_en),
		.status_out(status_out),
		.dmem_bus_sel(dmem_bus_sel),
		.done(done)
	);
endmodule