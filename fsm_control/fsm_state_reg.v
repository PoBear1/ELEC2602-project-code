module fsm_state_register(clock, rst, enable, next_state, state);
	input clock, rst, enable;
	input[3:0] next_state;
	input[3:0] state;
	always @(posedge clock or posedge rst) begin
		if(rst) begin state <= 4'b0; end
		else if(enable) begin state <= next_state; end
	end
endmodule