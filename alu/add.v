module add #(parameter N = 8)(
	input[N - 1:0] a, input[N - 1:0] b, 
	output[N - 1:0] x, 
	// status reg carry
	output cout, 
	// status reg zero
	output z, 
	// status reg neg
	output n,
	// signed overflow
	output o
);
	adc #(.N(N)) ad (.a(a), .b(b), .c(0), .x(x), .cout(cout), .z(z), .n(n), .o(o));
endmodule