module lsl #(parameter N = 8) (input[N - 1:0] a, output[N - 1:0] b, output c);
	assign c = a[N - 1];
	add adder(.a(a), .b(b), .c(0), )
endmodule