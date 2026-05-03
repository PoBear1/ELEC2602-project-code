module adc #(parameter N = 8)(
	input[N - 1:0] a, input[N - 1:0] b, input c, 
	output[N - 1:0] x, 
	// status reg carry
	output cout, 
	// status reg zero
	output z, 
	// status reg neg
	output n,
	// status reg signed, i.e. are we dealing with signed 
	output s,
	// signed overflow 
	output o
);
	wire[N:0] carry;
	assign carry[0] = c;
	assign cout = carry[N];
	assign z = (x == 0);
	assign o = (a[N - 1] & b[N - 1] & (~x[N - 1])) | ((~a[N - 1]) & (~b[N - 1]) & x[N - 1]);
	assign n = (x[N - 1] == 1);
	assign s = n ^ o;
	genvar i;
	generate
		for(i = 0; i < N; i = i + 1) begin : full_add_block
			full_add fa(.a(a[i]), .b(b[i]), .c(carry[i]), .r(x[i]), .cout(carry[i + 1]));
		end
	endgenerate
endmodule