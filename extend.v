module extend #(`include "parameters.vh") (
	input wire [12:0] imm,
	output wire [WORD_SIZE-1:0] imm_ext
);
	assign imm_ext = {{19{imm[12]}}, imm};
endmodule
