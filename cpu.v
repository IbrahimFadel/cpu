module cpu #(`include "parameters.vh") (
	input wire clk, resetn, pre_en, en,
	output wire [WORD_SIZE-1:0] addr,
	input wire [WORD_SIZE-1:0] read_data,
	output wire mem_write,
	output wire [WORD_SIZE-1:0] write_data,
	output wire mem_src,
	output wire [WORD_SIZE-1:0] A3, wd3,
	output wire reg_write
);
	`include "control_signals.vh"

	wire [WORD_SIZE-1:0] pc;
	wire [1:0] alu_a_src, alu_b_src;
	//wire reg_write;
	wire [1:0] result_src, imm_src;
	wire [3:0] alu_op;
	reg [WORD_SIZE-1:0] ar;
	wire [WORD_SIZE-1:0] alu_result;
	wire pc_write;
	wire addr_src;
	wire ar_write;
	wire ar_src;
	
	wire zero_cont, zero_write;
	reg zero;
	
	wire lt_cont, lt_write;
	reg lt;
	
	assign addr = addr_src == ADDR_SRC_PC ? pc :
					  addr_src == ADDR_SRC_AR ? ar :
					  {WORD_SIZE{1'bx}};
	
	reg [WORD_SIZE-1:0] instr_reg;
	wire instr_write;
	
//	wire [WORD_SIZE-1:0] instr = (instr_write && mem_src == SRC_CPU) ? read_data : instr_reg;
wire [WORD_SIZE-1:0] instr = instr_write ? read_data : instr_reg;
	wire [1:0] instr_type;
	wire [4:0] rd = instr[11:7];
	
	assign A3 = rd;
	
	wire [WORD_SIZE-1:0] cpu_write_data;
	//wire [WORD_SIZE-1:0] wd3;
	// If AR_SRC_REG_ADDR it means we are writing the contents of a register to memory for VGA printing later
	assign write_data = ar_src == AR_SRC_REG_ADDR ? wd3 : cpu_write_data;

	wire loaded_data_write;
	
	always @(posedge clk) begin
		if (!resetn) begin
			ar <= 0;
			instr_reg <= 0;
			zero <= 0;
			lt <= 0;
		end else begin
			if (en) begin
				if (instr_write) begin
					instr_reg <= read_data;
				end
				if (ar_write) begin
					ar <= ar_src == AR_SRC_ALU ? alu_result : 480 + rd;
				end
				if (zero_write) begin
					zero <= zero_cont;
				end
				if (lt_write) begin
					lt <= lt_cont;
				end
			end
		end
	end
	
	controller ctrl(
		clk, resetn, pre_en, en,
		instr,
		zero, zero_write,
		lt, lt_write,
		instr_write,
		instr_type,
		result_src,
		mem_write,
		addr_src, pc_write,
		alu_a_src, alu_b_src,
		reg_write,
		imm_src, alu_op,
		ar_write, ar_src,
		mem_src,
		loaded_data_write
	);
	datapath dp(
		clk, resetn, en,
		result_src,
		pc_write,
		alu_a_src, alu_b_src,
		reg_write,
		imm_src, alu_op,
		zero_cont, lt_cont, pc,
		instr, instr_type,
		alu_result, cpu_write_data, read_data,
		wd3,
		loaded_data_write
	);


	// 0101001010110101

	// 0101
endmodule
