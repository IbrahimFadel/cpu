module pc_reg #(
		parameter WORD_SIZE=16
	) (
		input clk, reset,
		input inc,
		output [WORD_SIZE-1:0] out
	);

	reg [WORD_SIZE-1:0] count;

	always @(posedge clk) begin
		if (reset == `RESET) begin
			count <= 0;
		end else if (inc) begin
			count <= count + 1;
		end
	end

	assign out = count;
endmodule
