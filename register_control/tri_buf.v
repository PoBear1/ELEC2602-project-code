module tri_buf #(parameter N = 8) (
	input [N - 1:0] a, 
	input en,
	output reg[N - 1:0] b
);
	
	always @(en or a) begin
		if (en) begin
			b = a;
		end else begin
			b = {N{1'bz}};
		end
	end
endmodule