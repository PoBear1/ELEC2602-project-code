module dec #(parameter N = 16) (
	input[N - 1:0] a,
	output[N - 1:0] x,
	output cout,
	output z,
	output n,
	output o
);
	add #(.N(N)) decrement(
		.a(a), .b(~0), .x(x), 
		.cout(cout), .z(z), .n(n), .o(o)
	);
endmodule
