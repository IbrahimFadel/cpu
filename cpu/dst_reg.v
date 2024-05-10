`include "sizes.vh"

module dst_reg #(
		parameter SIZE=8
	) (
		input clk, reset,
		input [SIZE-1:0] in,
		input load,
		output [SIZE-1:0] out
	);

	reg [SIZE-1:0] data;
	
	always @(posedge clk) begin
		if (load) begin
			data <= in;
		end
	end

	assign out = data;
endmodule
