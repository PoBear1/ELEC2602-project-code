module fsm_next (
	input[3:0] state,
	input[15:0] cur_in,
	output[3:0] reg next_state
);
	always @(cur_in) begin
		if(cur_in[15:12] == 4'b1111) begin
			// ldi, should be just a single state
			if(state == 1) begin
				next_state <= 0;
			end else begin
				next_state <= 1;
			end
		end else if(cur_in[15:12] == 4'b1110) begin
			// mov, also single state
			if(state == 1) begin
				next_state <= 0;
			end else begin
				next_state <= 1;
			end
		end else if(cur_in[15:12] == 4'b1101) begin
			// add, has three states
			if(state < 3) begin
				next_state <= state + 1;
			end else begin
				next_state <= 0;
			end
		end else if(cur_in[15:12] == 4'b1100) begin
			// sub, has four states
			if(state < 4) begin
				next_state <= state + 1;
			end else begin
				next_state <= 0;
			end
		end
	end
endmodule