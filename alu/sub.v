module one_comp #(parameter N = 16) (
	input[N - 1:0] a, output[N - 1:0] comp_a, 
	output cout,
	output z,
	output n,
	output o
);
	assign comp_a = ~a;
	assign z = (a == 0);
	assign cout = 1;
	assign n = comp_a[N - 1];
	assign o = 0;
endmodule

module two_comp #(parameter N = 16) (
	input[N - 1:0] a, output[N - 1:0] comp_a, 
	output cout,
	output z,
	output n,
	output o
);
	assign comp_a = ~a + 1;
	assign z = (a == 0);
	assign cout = ~z;
	assign n = comp_a[N - 1];
	assign o = (comp_a == a);
endmodule