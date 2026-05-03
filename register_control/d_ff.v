module d_ff #(parameter N = 8) (input[N - 1:0] d, input clk, input rst, input en, output[N - 1:0] reg q);
	always @(posedge clk or posedge rst) begin
		if(rst) begin q <= 0; end
		else if(en) begin q <= d; end
	end
endmodule