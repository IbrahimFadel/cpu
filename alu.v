module alu #(`include "parameters.vh") (
	input wire [WORD_SIZE-1:0] A, B,
	input wire [3:0] operation,
	output reg [WORD_SIZE-1:0] result,
	output wire zero
);
	`include "control_signals.vh"
	
	assign zero = result == {WORD_SIZE{1'b0}};

	always @ (*) begin
		case (operation)
			ALU_OP_ADD: result = A + B;
			ALU_OP_SUB: result = A - B;
			ALU_OP_MUL: result = A * B;
			ALU_OP_DIV: result = A / B;
			ALU_OP_SLL: result = A << B;
			ALU_OP_SRL: result = A >> B;
			ALU_OP_XOR: result = A ^ B;
			ALU_OP_OR: result = A | B;
			ALU_OP_AND: result = A & B;
			ALU_OP_LT: result = A < B;
			default: result = {{WORD_SIZE}{1'bx}};
		endcase
	end
endmodule
