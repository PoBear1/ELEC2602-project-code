module multiplex2n #(parameter in = 3, parameter out = 8) (
	input[in - 1:0] pick,
	output[out - 1:0] sig
);
	generate
		if(in == 1 && out == 2) begin : base
			if(pick == 0) begin assign sig = 2'b10; end
			else          begin assign sig = 2'b01; end
		end else begin : recurse
			if(pick[in - 1] == 1) begin
				assign sig[out/2 - 1:0] = 0;
				multiplex2n #(.in(in - 1), .out(out/2)) multiplex_down(.pick(pick[in - 2:0]), .sig(sig[out - 1:out/2]));
			end else begin
				assign sig[out:out/2 - 1] = 0;
				multiplex2n #(.in(in - 1), .out(out/2)) multiplex_down(.pick(pick[in - 2:0]), .sig(sig[out/2 - 1:0]));
			end
		end
	endgenerate
endmodule

module reg_block #(parameter n = 3, parameter regs = 8, parameter N = 16) (
	input[N - 1:0] d,
	input clk,
	input[n - 1:0] reg_tri,
	input[n - 1:0] reg_en,
	input reg_rst,
	output[N - 1:0] w
);
	genvar i;
	wire[regs - 1:0] reg_sel_tri, reg_sel_en;
	multiplex2n #(.in(n), .out(regs)) select_tri(.pick(reg_tri), .sig(reg_sel_tri));
	multiplex2n #(.in(n), .out(regs)) select_en(.pick(reg_en), .sig(reg_sel_en));
	generate
		for(i = 0; i < regs; i = i + 1) begin : small_unit
			wire intermediate;
			reg_unit #(.N(N)) register_block(.d(d), .clk(clk), .reg_tri(reg_sel_tri[i]), .reg_en(reg_sel_en[i]), .reg_rst(reg_rst), .w(intermediate));
			if(intermediate[0] != 1'bz) begin assign w = intermediate; end
		end
	endgenerate
endmodule