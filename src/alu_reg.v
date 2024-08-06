`include "sizes.vh"

module alu_reg #(
		parameter WORD_SIZE=`WORD_SIZE
	) (
		input clk, reset,
		input [WORD_SIZE-1:0] in,
		input load,
		output [WORD_SIZE-1:0] out
	);

	reg [WORD_SIZE-1:0] data;
	
	always @(posedge clk) begin
		if (load) begin
			data <= in;
		end
	end

	assign out = data;
endmodule