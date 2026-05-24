module slow_ctr #(parameter count_up_to = 50000000) (clock, rst, q);
	input clock, rst;
	output reg q;
	reg[31:0] q1;
	always @(posedge clock or posedge rst) begin
		if(rst) begin q1 <= 32'b0; q <= 0; end
		else begin
			if(q1 == count_up_to - 1) begin
				q1 <= 0;
				q <= 1;
			end else begin
				q1 <= q1 + 1;
				q <= 0;
			end
		end
	end
endmodule

module fpga_processor #(parameter count_up_to = 50000000) (
	input CLOCK_50,
	input [3:0] KEY,
	output [9:0] LEDR, 
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);
	wire reset = ~KEY[0];
	wire[3:0] fsm_state;
	wire[3:0] low_4_pc_ptr;
	wire[3:0] low_4_opcode;
	wire[15:0] r0, r1, r2;
	wire[3:0]  r0_low, r1_low, r2_low;
	wire slow_clock_wire;
	slow_ctr #(.count_up_to(count_up_to)) slow_clock(.clock(CLOCK_50), .rst(reset), .q(slow_clock_wire));
	processor proc (
        .clock(slow_clock_wire),
        .reset(reset), 
		.observable_pc(low_4_pc_ptr),
		.observable_state(fsm_state),
		.observable_opcode(low_4_opcode),
		.observable_r0(r0),
		.observable_r1(r1),
		.observable_r2(r2)
    );
	assign r0_low = r0[3:0];
	assign r1_low = r1[3:0];
	assign r2_low = r2[3:0];
	decoder_7seg seg_1(.binary(r0_low), .sevenSeg(HEX4));
	assign HEX5 = (r0_low > 9) ? 7'b1111001 : 7'b1000000;
	decoder_7seg seg_2(.binary(r1_low), .sevenSeg(HEX2));
	assign HEX3 = (r1_low > 9) ? 7'b1111001 : 7'b1000000;
	decoder_7seg seg_3(.binary(low_4_pc_ptr), .sevenSeg(HEX0));
	assign HEX1 = (low_4_pc_ptr > 9) ? 7'b1111001 : 7'b1000000;
	assign LEDR = (low_4_opcode == 0) ? 10'b1111111111 : 10'b0000000000;
endmodule