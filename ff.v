module ff #(parameter WIDTH = 32) (
	input wire clk, resetn,
	input wire [WIDTH-1:0] data,
	output reg [WIDTH-1:0] q
);
	always @(posedge clk) begin
		if (!resetn) begin
			q <= {{WIDTH}{1'b0}};
		end else begin
			q <= data;
		end
	end
endmodule
