// status[0] = Z (zero), status[1] = N (negative), status[2] = C (carry), status[3] = V (overflow)
module fsm_next #(parameter op_size = 16, parameter in_size = 8) (
	input[3:0] state,
	input[3:0] status,
	input[op_size - 1:0] cur_in,
	output reg[3:0] next_state
);
	always @(cur_in, state, status) begin
		next_state = 0;
		$display("Should be here: %8b", cur_in[op_size - 1:op_size - in_size]);
		$display("Actual full instruction: %16b", cur_in);
		$display("In_size = %d", in_size);
		if(cur_in[op_size - 1:op_size - in_size] == 8'b00000001) begin
			// ldi, should be just a single state
			$display("Should be there");
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
			// ld, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end else if(cur_in[op_size - 1:op_size - in_size] == 8'b00001100) begin
			// st, has one state
			if(state == 1) begin
				next_state = 0;
			end else begin
				next_state = 1;
			end
		end
	end
endmodule