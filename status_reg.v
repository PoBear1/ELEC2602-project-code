module status_reg #(parameter N = 16) (
	input[N - 1:0] d,
	input clk,
	input reg_tri,
	input reg_en,
	input reg_rst,
	output[N - 1:0] q,
	output[N - 1:0] w
);
	d_ff #(.N(N)) ff(.d(d), .clk(clk), .en(reg_en), .rst(reg_rst), .q(q));
	tri_buf #(.N(N)) buffer (.a(q), .en(reg_tri), .b(w));
endmodule