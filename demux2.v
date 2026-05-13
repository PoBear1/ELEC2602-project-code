module demux #(
	parameter N = 16
) (
	input[N - 1:0]  in,
	input           sel,
	output[N - 1:0] reg path_0, 
	output[N - 1:0] reg path_1
);
	always @(in, sel) begin
		if(sel == 0) begin
			path_0 = in;
			path_1 = 0;
		end else begin
			path_0 = 0;
			path_1 = in;
		end
	end
endmodule