module fsm_next #(parameter op_size = 16, parameter in_size = 4) (
	input[3:0] state,
	input[op_size - 1:0] cur_in,
	output[3:0] reg next_state
);
	always @(cur_in) begin
		if(cur_in[op_size - 1:op_size - in_size] == 15) begin
			// ldi, should be just a single state
			if(state == 1) begin
				next_state <= 0;
			end else begin
				next_state <= 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 14) begin
			// mov, also single state
			if(state == 1) begin
				next_state <= 0;
			end else begin
				next_state <= 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 13) begin
			// add, has three states
			if(state < 3) begin
				next_state <= state + 1;
			end else begin
				next_state <= 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 12) begin
			// sub, has four states
			if(state < 4) begin
				next_state <= state + 1;
			end else begin
				next_state <= 0;
			end
		end
	end
endmodule