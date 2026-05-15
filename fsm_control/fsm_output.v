module fsm_output #(
	parameter block = 4,
	parameter op_size = 16,
	parameter in_size = 8,
	parameter alu_modes = 4,
	parameter N = 16,
	parameter imm_l = 16
) (
	input[op_size - 1:0] cur_in,
	input[3:0] state,
	input[3:0] status,
	output reg[block:0] r_en,
	output reg[block:0] r_out,
	output reg a_en,
	output reg g_en,
	output reg g_out,
	output reg dmem_en,
	output reg dmem_out,
	output reg pc_en,
	output reg jmp_en,
	output reg[alu_modes - 1:0] alu_mode,
	output reg status_en,
	output reg status_out,
	output reg dmem_bus_sel,
	output reg imm_data_en,
	output reg done
);
	always @(state, cur_in, status) begin
		r_en         = 0;
		r_out        = 0;
		a_en         = 0;
		g_en         = 0;
		g_out        = 0;
		dmem_en      = 0;
		dmem_out     = 0;
		pc_en        = 0;
		jmp_en       = 0;
		alu_mode     = 0;
		status_en    = 0;
		status_out   = 0;
		dmem_bus_sel = 0;
		imm_data_en  = 0;
		done         = (state == 0);
		if(state != 0) begin
			if(cur_in[op_size - 1:op_size - in_size] == 1) begin
				// ldi
				r_en[block]		  = 1;
				r_en[block - 1:0] = cur_in[block - 1:0];
				imm_data_en       = 1;
				dmem_bus_sel      = 1;
				pc_en             = 1;
			end else if(cur_in[op_size - 1:op_size - in_size] == 2) begin
				// mov
				r_en[block]		   = 1;
				r_en[block - 1:0]  = cur_in[block * 2 - 1:block];
				r_out[block]	   = 1;
				r_out[block - 1:0] = cur_in[block - 1:0];
				pc_en              = 1;
			end else if(cur_in[op_size - 1:op_size - in_size] == 3) begin
				// add
				if(state == 1) begin
					a_en 			   = 1; 	
					r_out[block]	   = 1;	
					r_out[block - 1:0] = cur_in[block - 1:0];
				end else if(state == 2) begin
					alu_mode = 4'd1;
					g_en 			   = 1;
					status_en		   = 1;
					r_out[block]	   = 1;
					r_out[block - 1:0] = cur_in[2 * block - 1:block];
				end else if(state == 3) begin
					g_out			   = 1;
					r_en[block]		   = 1;
					r_en[block - 1:0]  = cur_in[2 * block - 1:block];
					pc_en              = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 4) begin
				// neg
				alu_mode = 2;
				if(state == 1) begin
					r_out[block]	   = 1;
					r_out[block - 1:0] = cur_in[block - 1:0];
					g_en 			   = 1;
					status_en		   = 1;
				end else if(state == 2) begin
					g_out			   = 1;
					r_en[block]	 	   = 1;
					r_en[block - 1:0]  = cur_in[block - 1:0];
					pc_en              = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 5) begin
				// sub
				if(state == 1) begin
					alu_mode = 2;
					r_out[block]	   = 1;
					r_out[block - 1:0] = cur_in[block - 1:0];
					g_en 			   = 1;
				end else if(state == 2) begin
					g_out			   = 1;
					a_en			   = 1;
				end else if(state == 3) begin
					alu_mode = 1;
					r_out[block]	   = 1;
					r_out[block - 1:0] = cur_in[2 * block - 1:block];
					g_en 			   = 1;
					status_en		   = 1;
				end else if(state == 4) begin
					g_out			   = 1;
					r_en[block]		   = 1;
					r_en[block - 1:0]  = cur_in[2 * block - 1:block];
					pc_en              = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 6) begin
				// inc
				alu_mode = 5;
				if(state == 1) begin
					r_out[block]	   = 1;
					r_out[block - 1:0] = cur_in[block - 1:0];
					g_en 			   = 1;
					status_en		   = 1;
				end else if(state == 2) begin
					g_out			   = 1;
					r_en[block]	 	   = 1;
					r_en[block - 1:0]  = cur_in[block - 1:0];
					pc_en              = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 7) begin
				// dec
				alu_mode = 6;
				if(state == 1) begin
					r_out[block]	   = 1;
					r_out[block - 1:0] = cur_in[block - 1:0];
					g_en 			   = 1;
					status_en		   = 1;
				end else if(state == 2) begin
					g_out			   = 1;
					r_en[block]	 	   = 1;
					r_en[block - 1:0]  = cur_in[block - 1:0];
					pc_en              = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 8) begin
				// jmp
				if(state == 1) begin
					jmp_en 		 = 1;
					imm_data_en  = 1;
					dmem_bus_sel = 1;
					pc_en		 = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 9) begin
				// brne
				if(state == 1) begin
					if(!status[0]) begin
						jmp_en 		 = 1;
						imm_data_en  = 1;
						dmem_bus_sel = 1;
					end
					pc_en = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 10) begin
				// breq
				if(state == 1) begin
					if(status[0]) begin
						jmp_en 		 = 1;
						imm_data_en  = 1;
						dmem_bus_sel = 1;
					end
					pc_en = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 11) begin
				// lds
				if(state == 1) begin
					dmem_out		  = 1;
					r_en[block] 	  = 1;
					r_en[block - 1:0] = cur_in[block - 1:0];
					pc_en	    	  = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 12) begin
				// sts
				if(state == 1) begin
					dmem_en			   = 1;
					r_out[block] 	   = 1;
					r_out[block - 1:0] = cur_in[block - 1:0];
					pc_en	    	   = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 13) begin
				// cp, basically sub but no loading at end
				if(state == 1) begin
					alu_mode = 2;
					r_out[block]	   = 1;
					r_out[block - 1:0] = cur_in[block - 1:0];
					g_en 			   = 1;
				end else if(state == 2) begin
					g_out			   = 1;
					a_en			   = 1;
				end else if(state == 3) begin
					alu_mode = 1;
					r_out[block]	   = 1;
					r_out[block - 1:0] = cur_in[2 * block - 1:block];
					g_en 			   = 1;
					status_en		   = 1;
					pc_en              = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 14) begin
				// brsh
				if(state == 1) begin
					if(status[0] | !status[1]) begin
						jmp_en 		 = 1;
						imm_data_en  = 1;
						dmem_bus_sel = 1;
					end
					pc_en = 1;
				end
			end else if(cur_in[op_size - 1:op_size - in_size] == 15) begin
				// brlo
				if(state == 1) begin
					if(status[1]) begin
						jmp_en 		 = 1;
						imm_data_en  = 1;
						dmem_bus_sel = 1;
					end
					pc_en = 1;
				end
			end
		end
	end
endmodule
