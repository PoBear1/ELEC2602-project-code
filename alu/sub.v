module one_comp #(parameter N = 8) (input[N - 1:0] a, output[N - 1:0] comp_a);
	assign comp_a = !a;
endmodule

module sub #(parameter N = 8) (input[N - 1:0] a, input[N - 1:0] b, output[N - 1:0] r, output c, output z, )