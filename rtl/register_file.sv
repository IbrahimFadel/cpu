module register_file
	#(`include "parameters.vh")
	(
		input logic clk, reset,
		input logic [REGISTER_ADDRESS_WIDTH-1:0] a1, a2,
		output logic [XLEN-1:0] d1, d2,
		input logic [REGISTER_ADDRESS_WIDTH-1:0] a3,
		input logic [XLEN-1:0] d3
		input logic we3,
	)

  logic [XLEN-1:0] registers[NUM_REGISTERS-1:1];

	always @(posedge clk) begin
		if (reset) begin
			integer i;
			for (i = 1; i < NUM_REGISTERS; i = i + 1) begin
				registers[i] = '0;
			end
		end else if (we3 && a3 != 0) begin
			regs[a3] = d3;
		end
	end

	always @(posedge clk)
    d1 = (a1 == 0) ? 0 : regs[a1];
  always @(posedge clk)
    d2 = (a2 == 0) ? 0 : regs[a2];
endmodule
