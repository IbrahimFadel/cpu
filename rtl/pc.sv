module pc
	#(
		`include "parameters.vh",
		parameter int PC_RESET_ADDR = 'h1000
	)
	(
		input logic clk, reset,
		input logic [XLEN-1:0] next,
		output logic [XLEN-1:0] out,
		input logic en
	)
	always @(posedge clk) begin
    if (reset)
      out = PC_RESET_ADDR;
    else if (en)
      out = next;
  end
endmodule
