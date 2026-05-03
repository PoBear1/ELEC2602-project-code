module full_add(input a, input b, input c, output r, output cout);
	assign r = (a ^ b) ^ c;
	assign cout = (a & b) | (b & c) | (c & a);
endmodule