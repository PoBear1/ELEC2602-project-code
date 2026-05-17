module demux #(
	parameter N = 16
) (
	input[N - 1:0]  in,
	input           sel,
	output reg [N - 1:0] path_0, 
	output reg [N - 1:0] path_1
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