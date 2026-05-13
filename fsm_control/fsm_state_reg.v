module fsm_state_register(
	input clock, 
	input rst, 
	input enable, 
	input[3:0] next_state, 
	output[3:0] reg state
);
	always @(posedge clock or posedge rst) begin
		if(rst) begin state <= 4'b0; end
		else if(enable) begin state <= next_state; end
	end
endmodule