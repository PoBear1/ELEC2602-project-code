// alu_mode: 0=idle, 1=add, 2=neg (two's comp), 3=adc, 4=one_comp, 5=inc, 6=dec
// status: [0]=Z, [1]=N, [2]=C, [3]=V
module alu #(
	parameter N = 16, 
	parameter modes = 4
) (
	input[N - 1:0] a,
	input[N - 1:0] b,
	input[modes - 1:0] alu_mode,
	input[3:0] prev_stat,
	output reg[N - 1:0] out,
	output reg[3:0] status
);
	wire[N - 1:0] add_x, adc_x, neg_x, not_x, inc_x, dec_x;
	wire[3:0] add_stat, adc_stat, inc_stat, dec_stat, neg_stat, not_stat;

	add #(.N(N)) adder(.a(a), .b(b), .x(add_x), .cout(add_stat[2]), .z(add_stat[0]), .n(add_stat[1]), .o(add_stat[3]));
	adc #(.N(N)) add_c(.a(a), .b(b), .c(prev_stat[2]), .x(adc_x), .cout(adc_stat[2]), .z(adc_stat[0]), .n(adc_stat[1]), .o(adc_stat[3]));
	two_comp #(.N(N)) neg(.a(b), .comp_a(neg_x), .cout(neg_stat[2]), .z(neg_stat[0]), .n(neg_stat[1]), .o(neg_stat[3]));
	one_comp #(.N(N)) not_block(.a(b), .comp_a(not_x), .cout(not_stat[2]), .z(not_stat[0]), .n(not_stat[1]), .o(not_stat[3]));
	inc #(.N(N)) incr(.a(b), .x(inc_x), .cout(inc_stat[2]), .z(inc_stat[0]), .n(inc_stat[1]), .o(inc_stat[3]));
	dec #(.N(N)) decr(.a(b), .x(dec_x), .cout(dec_stat[2]), .z(dec_stat[0]), .n(dec_stat[1]), .o(dec_stat[3]));

	always @(alu_mode, b, prev_stat, add_x, adc_x, neg_x, not_x, inc_x, dec_x, add_stat, adc_stat, inc_stat, dec_stat, neg_stat, not_stat) begin
		out = b;
		status = 0;
		if(alu_mode == 1) begin
			out = add_x;
			status = add_stat;
		end else if(alu_mode == 3) begin
			out = adc_x;
			status = adc_stat;	
		end else if(alu_mode == 2) begin
			out = neg_x;
			status = neg_stat;	
		end else if(alu_mode == 4) begin
			out = not_x;
		end else if(alu_mode == 5) begin
			out = inc_x;
			status = inc_stat;	
		end else if(alu_mode == 6) begin
			out = dec_x;
			status = dec_stat;	
		end 
	end
endmodule
