module datapath #(`include "parameters.vh") (
	input wire clk, resetn, en,
	input wire [1:0] result_src,
	input wire pc_write,
	input wire [1:0] alu_a_src, alu_b_src,
	input wire reg_write,
	input wire [1:0] imm_src,
	input wire [3:0] alu_op,
	output wire zero, lt,
	output reg [WORD_SIZE-1:0] pc,
	input wire [WORD_SIZE-1:0] instr,
	input wire [1:0] instr_type,
	output wire [WORD_SIZE-1:0] alu_result, write_data,
	input wire [WORD_SIZE-1:0] read_data,
	output wire [WORD_SIZE-1:0] wd3,
	input wire loaded_data_write
);
	`include "control_signals.vh"
	
	wire [WORD_SIZE-1:0] pc_next;
	wire [WORD_SIZE-1:0] imm_ext;
	wire [WORD_SIZE-1:0] A, B;
//	wire [WORD_SIZE-1:0] wd3;
	reg [WORD_SIZE-1:0] loaded_data;

	always @(posedge clk) begin
		if (!resetn) begin
			pc <= {WORD_SIZE{1'd0}};
			loaded_data <= 0;
//			pc <= 14;
		end else if (en) begin
			if (pc_write) begin
				pc <= pc_next;
			end
			if (loaded_data_write) begin
				loaded_data <= read_data;
			end
		end
	end
	
	assign pc_next = alu_result;
	
	assign lt = alu_result == 1;

	wire [4:0] rs1 = instr[19:15];
	wire [4:0] rs2 = instr[24:20];
	wire [4:0] rd = instr[11:7];
	wire [12:0] imm = instr_type == ITYPE ? {instr[31], instr[31:20]} :
							instr_type == STYPE ? {instr[31], instr[31:25], instr[11:7]} :
							instr_type == BTYPE ? {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0} :
														 12'bx;

	wire [WORD_SIZE-1:0] rd1;
	register_file rf(
		clk, resetn,
		rs1, rs2, rd,
		wd3,
		reg_write,
		rd1, write_data
	);
	extend ext(imm, imm_ext);

	mux2 amux (rd1, pc, alu_a_src, A);
	mux3 bmux (write_data, imm_ext, 1, alu_b_src, B);
	
	alu alu(
		A, B, alu_op, alu_result, zero
	);
	
	assign wd3 = result_src == RESULT_SRC_ALU ? alu_result :
					 result_src == RESULT_SRC_RD  ? read_data :
					 result_src == RESULT_SRC_LOADED  ? loaded_data :
					 {WORD_SIZE{1'bx}};
endmodule
