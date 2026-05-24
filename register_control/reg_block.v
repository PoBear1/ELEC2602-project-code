module multiplex2n #(parameter in = 3, parameter out = 8) (
	input[in - 1:0] pick,
	output[out - 1:0] sig
);
	genvar i;
	generate
		for(i = 0; i < out; i = i + 1) begin : decode
			assign sig[i] = (pick == i);
		end
	endgenerate
endmodule

module reg_block #(parameter n = 4, parameter regs = 16, parameter N = 16) (
	input[N - 1:0] d,
	input clk,
	input[n:0] reg_tri,
	input[n:0] reg_en,
	input reg_rst,
	output[N - 1:0] w,
	output[N - 1:0] r0,
	output[N - 1:0] r1,
	output[N - 1:0] r2
);
	genvar i;
	wire[regs - 1:0] reg_sel_tri, reg_sel_en;
	multiplex2n #(.in(n), .out(regs)) select_tri(.pick(reg_tri[n - 1:0]), .sig(reg_sel_tri));
	multiplex2n #(.in(n), .out(regs)) select_en(.pick(reg_en[n - 1:0]), .sig(reg_sel_en));
	generate
		for(i = 0; i < regs; i = i + 1) begin : small_unit
			reg_unit #(.N(N)) register_block(.d(d), .clk(clk), .reg_tri(reg_sel_tri[i] & reg_tri[n]), .reg_en(reg_sel_en[i] & reg_en[n]), .reg_rst(reg_rst), .w(w));
		end
	endgenerate
	reg_unit #(.N(N)) register_block0(.d(d), .clk(clk), .reg_tri(1), .reg_en(reg_sel_en[0] & reg_en[n]), .reg_rst(reg_rst), .w(r0));
	reg_unit #(.N(N)) register_block1(.d(d), .clk(clk), .reg_tri(1), .reg_en(reg_sel_en[1] & reg_en[n]), .reg_rst(reg_rst), .w(r1));
	reg_unit #(.N(N)) register_block2(.d(d), .clk(clk), .reg_tri(1), .reg_en(reg_sel_en[2] & reg_en[n]), .reg_rst(reg_rst), .w(r2));
endmodule