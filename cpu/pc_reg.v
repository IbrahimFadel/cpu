`include "sizes.vh"

module pc_reg #(
		parameter WORD_SIZE=`WORD_SIZE
	) (
		input clk, reset,
		input inc,
		output [WORD_SIZE-1:0] out
	);

	reg [WORD_SIZE-1:0] count;

	initial begin
		count = 0;
	end

	always @(posedge clk) begin
		if (reset) begin
			count <= 0;
		end else if (inc) begin
			count <= count + 1;
		end
	end

	assign out = count;
endmodule