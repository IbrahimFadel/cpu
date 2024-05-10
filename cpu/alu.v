`include "sizes.vh"
`include "instrs.vh"
`include "registers.vh"

module alu #(
		parameter WORD_SIZE=`WORD_SIZE
	) (
		input [WORD_SIZE-1:0] a, b,
		input [3:0] op,
		output reg [WORD_SIZE-1:0] alu_out
	);

	always @(a, b, op) begin
		case (op)
			`OP_ADD: alu_out = a + b;
			default: alu_out = {(WORD_SIZE){1'bz}};
		endcase
	end
endmodule
