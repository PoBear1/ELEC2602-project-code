module processor #(
	parameter block = 4,
	parameter num_regs = 16, 
	parameter alu_modes = 4,
	parameter in_size = 8,
	parameter N = 8,
	parameter imm_l = N,
	parameter opcode_size = 16 + N,
	parameter mem_len = 1 << imm_l
) (
	input clock,
	input reset
);
	wire[N - 1:0] data_bus, alu_a, alu_out, to_data_bus;
	wire[15:0] opcode;
	wire[imm_l - 1:0] imm; 
	wire[imm_l - 1:0] dmem_addr, pc_addr;
	wire[opcode_size - 1:0] cur_instruction;
	wire[3:0] fsm_state;
	wire a_en;
	wire g_en, g_out;
	wire dmem_en, dmem_out;
	wire reg_tri, reg_en;
	wire[block - 1:0] reg_num_tri, reg_num_en;
	wire pc_en, jmp_en;
	wire[alu_modes - 1:0] alu_mode;
	wire status_en, status_out;
	wire[7:0] stat_in, alu_stat;
	wire dmem_bus_sel, imm_data_en;
	wire done;

	// dmem
	reg_block #(
		.n(imm_l),
		.regs(mem_len),
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
	pmem_block #(
		.imm_l(imm_l),
		.opcode_size(opcode_size),
		.mem_len(mem_len)
	) pmem(
		.addr(pc_addr),
		.w(cur_instruction)
	);

	// opcode/imm wires
	assign opcode = cur_instruction[opcode_size - 1:imm_l]; 
	assign imm = cur_instruction[imm_l - 1:0];

	// demux imm to either bus or dmem
	demux #(.N(N)) demuxer(
		.in(imm),
		.sel(dmem_bus_sel),
		.path_0(dmem_addr),
		.path_1(to_data_bus)
	);

	tri_buf #(.N(N)) demux_buf(
		.a(to_data_bus),
		.en(imm_data_en),
		.b(data_bus)
	);

	// program counter
	pc #(
		.N(imm_l)
	) pc_reg(
		.clk(clock),
		.rst(reset),
		.pc_en(pc_en),
		.jmp_en(jmp_en),
		.jmp_offset(data_bus),
		.w(pc_addr)
	);

	// registers
	reg_block #(
		.n(block),
		.regs(num_regs),
		.N(N)
	) registers(
		.d(data_bus),
		.clk(clock),
		.reg_tri({reg_tri, reg_num_tri}),
		.reg_en({reg_en, reg_num_en}),
		.reg_rst(reset),
		.w(data_bus)
	);

	reg_unit #(
		.N(N)
	) A_reg(
		.d(data_bus),
		.clk(clock),
		.reg_tri(1'b1),
		.reg_en(a_en),
		.reg_rst(reset),
		.w(alu_a)
	);

	reg_unit #(
		.N(N)
	) G_reg(
		.d(alu_out),
		.clk(clock),
		.reg_tri(g_out),
		.reg_en(g_en),
		.reg_rst(reset),
		.w(data_bus)
	);

	// status register
	status_reg #(
		.N(8)
	) stat_reg(
		.d(alu_stat),
		.clk(clock),
		.reg_tri(status_out),
		.reg_en(status_en),
		.reg_rst(reset),
		.q(stat_in),
		.w(data_bus)
	);

	// alu
	alu #(
		.N(N), 
		.modes(alu_modes)
	) calculator(
		.a(alu_a),
		.b(data_bus),
		.alu_mode(alu_mode),
		.prev_stat(stat_in[3:0]),
		.out(alu_out),
		.status(alu_stat[3:0])
	);

	// controller
	fsm_control #(
		.block(block),
		.alu_modes(alu_modes),
		.opcode_size(16),
		.in_size(in_size),
		.N(N)
	) controller(
		.clock(clock),
		.rst(reset),
		.en(1'b1),
		.cur_instruction(opcode),
		.status(stat_in[3:0]),
		.state(fsm_state),
		.r_en({reg_en, reg_num_en}),
		.r_out({reg_tri, reg_num_tri}),
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