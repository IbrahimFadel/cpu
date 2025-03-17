module imm_extend
	#(`include "parameters.vh")
	(
		input logic [31:7] imm,
		input ImmExtendMode mode,
		output logic [XLEN-1:0] imm_ext
	);
	logic [XLEN-1:0] i_imm;
	logic [XLEN-1:0] s_imm;
	logic [XLEN-1:0] b_imm;
	logic [XLEN-1:0] u_imm;
	logic [XLEN-1:0] j_imm;

	assign u_imm = {imm[31:12], 12'b0};
	
	sign_extend #(.OUT(XLEN))
		i_extender(
			.in(imm[31:20]),
			.out(i_imm)
		);

	sign_extend #(.OUT(XLEN))
		s_extender(
			.in({imm[31:25],imm[11:7]}),
			.out(s_imm)
		);

	sign_extend #(.OUT(XLEN), .IN(13))
		b_extender(
			.in({imm[31], imm[7], imm[30:25], imm[11:8], 1'b0}),
			.out(b_imm)
		);

	sign_extend #(.OUT(XLEN), .IN(21))
		j_extender(
			.in({imm[31], imm[19:12], imm[20], imm[30:21], 1'b0}),
			.out(j_imm)
		);

	always_comb begin
		unique case (mode)
			IMM_EXTEND_MODE_I_INST:
				imm_ext = i_imm;
			IMM_EXTEND_MODE_S_INST:
				imm_ext = s_imm;
			IMM_EXTEND_MODE_B_INST:
				imm_ext = b_imm;
			IMM_EXTEND_MODE_U_INST:
				imm_ext = u_imm;
			IMM_EXTEND_MODE_J_INST:
				imm_ext = j_imm;
		default:
			imm_ext = {XLEN{1'bx}};
		endcase
	end
endmodule

module sign_extend
	#(
		parameter int OUT = 32,
		parameter int IN = 12
	)
	(
		input logic [IN-1:0] in,
		output logic [OUT-1:0] out
	);
  assign out = {{(OUT - IN){in[IN - 1]}}, in};
endmodule
