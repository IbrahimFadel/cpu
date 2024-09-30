module register #(
	parameter SIZE=16
) (
	input wire clk, reset,
	inout wire [SIZE-1:0] data,
	input wire load, enable
);
	reg [SIZE-1:0] val;

	always @(posedge clk) begin
		if (reset == `RESET) begin
			val <= 0;
		end else begin
			if (load) begin
				val <= data;
			end
		end
	end

	assign data = enable ? val : {(SIZE){1'bz}};
endmodule
