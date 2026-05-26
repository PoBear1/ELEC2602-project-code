module fsm_state_register #(
	parameter state_s = 4
) (
	input clock, 
	input rst, 
	input enable, 
	input[state_s - 1:0] next_state, 
	output reg[state_s - 1:0] state
);
	always @(posedge clock or posedge rst) begin
		if(rst) begin state <= 4'b0; end
		else if(enable) begin state <= next_state; end
	end
endmodule