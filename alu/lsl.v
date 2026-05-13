module lsl #(parameter N = 8) (
	input[N - 1:0] a, output[N - 1:0] b, 
	output cout,
	output z,
	output n,
	output o
);
	assign b = a << 1;
	assign cout = a[N - 1];
	assign z = (b == 0);
	assign n = b[N - 1];
	assign o = n ^ cout;
endmodule