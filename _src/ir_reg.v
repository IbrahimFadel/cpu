module ir_reg (
		input clk, reset,
		input [7:0] in,
		input load,
		output [7:0] out
	);
	reg [7:0] data;
	
	always @(posedge clk) begin
		if (load) begin
			data <= in;
		end
	end

	assign out = data;
endmodule
