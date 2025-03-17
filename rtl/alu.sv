module alu
	// `include "parameters.vh"
	#(parameter int XLEN = 32)
	(
		input AluOp op,
		input logic [XLEN-1:0] a, b,
		output logic [XLEN-1:0] out,
		output logic zero
	);
	always_comb begin : alu_switch
		unique case (op)
			ALU_OP_ADD: out = a + b;
			ALU_OP_SLT: out = {{XLEN - 1{1'b0}}, ($signed(a) < $signed(b))};
			ALU_OP_SLTU: out = {{XLEN - 1{1'b0}}, (a < b)};
			ALU_OP_AND: out = a & b;
			ALU_OP_OR: out = a | b;
			ALU_OP_XOR: out = a ^ b;
			ALU_OP_SLL: out = a << b;
			ALU_OP_SLR: out = a >> b;
			ALU_OP_SUB: out = a - b;
			ALU_OP_SRA: out = $signed(a) >>> b;
			default: out = {XLEN{1'bx}};
		endcase
	end

	assign zero = (out == 0);
endmodule
