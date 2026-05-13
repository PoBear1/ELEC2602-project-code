// status[0] = Z (zero), status[1] = N (negative), status[2] = C (carry), status[3] = V (overflow)
module fsm_next #(parameter op_size = 16, parameter in_size = 8) (
	input[3:0] state,
	input[op_size - 1:0] cur_in,
	input[3:0] status,
	output reg[3:0] next_state
);
	always @(cur_in, state, status) begin
		next_state = 0;
		if(cur_in[op_size - 1:op_size - in_size] == 1) begin
			// ldi, should be just a single state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 2) begin
			// mov, also single state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 3) begin
			// add, has three states
			if(state < 3) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 4) begin
			// neg, has two states
			if(state < 2) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 5) begin
			// sub, has four states
			if(state < 4) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 6) begin
			// in, has two states
			if(state < 2) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 7) begin
			// dec, has two states
			if(state < 2) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8) begin
			// jmp, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 9) begin
			// brne, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 10) begin
			// breq, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 11) begin
			// ld, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 12) begin
			// st, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end
	end
endmodule