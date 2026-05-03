module fsm_next (
	input[3:0] state,
	input[15:0] cur_in,
	output[3:0] reg next_state
);
	always @(cur_in) begin
		if(cur_in[15:12] == 4'b1110) begin
			// ldi, should be just a single state
			if(state == 1) begin
				next_state <= 0;
			end else begin
				next_state <= 1;
			end
		end
	end
endmodule