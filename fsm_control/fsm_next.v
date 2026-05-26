// status[0] = Z (zero), status[1] = N (negative), status[2] = C (carry), status[3] = V (overflow)
module fsm_next #(parameter op_size = 16, parameter in_size = 8, parameter state_s = 4) (
	input[state_s - 1:0] state,
	input[3:0] status,
	input[op_size - 1:0] cur_in,
	output reg[state_s - 1:0] next_state
);
	always @(cur_in, state, status) begin
		next_state = 0;
		if(cur_in[op_size - 1:op_size - in_size] == 8'b00000001) begin
			// ldi, should be just a single state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00000010) begin
			// mov, also single state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00000011) begin
			// add, has three states
			if(state < 3) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00000100) begin
			// neg, has two states
			if(state < 2) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00000101) begin
			// sub, has four states
			if(state < 4) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00000110) begin
			// in, has two states
			if(state < 2) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00000111) begin
			// dec, has two states
			if(state < 2) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001000) begin
			// jmp, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001001) begin
			// brne, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001010) begin
			// breq, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001011) begin
			// lds, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001100) begin
			// sts, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001101) begin
			// cp, has three states
			if(state < 3) begin
				next_state = state + 1;
			end else begin
				next_state = 0;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001110) begin
			// brsh, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001111) begin
			// brlo, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end
	end
endmodule