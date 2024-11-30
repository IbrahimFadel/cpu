module controller #(`include "parameters.vh") (
	input wire clk, resetn, pre_en, en,
	input wire [WORD_SIZE-1:0] instr,
	input wire zero,
	output wire zero_write,
	input wire lt,
	output wire lt_write,
	output wire instr_write,
	output wire [1:0] instr_type,
	output wire [1:0] result_src,
	output wire mem_write,
	output wire addr_src, pc_write,
	output wire [1:0] alu_a_src, alu_b_src,
	output wire reg_write,
	output wire [1:0] imm_src,
	output wire [3:0] alu_op,
	output wire ar_write, ar_src,
	output wire mem_src,
	output wire loaded_data_write
);
	`include "control_signals.vh"
	
	wire branch;
	reg [2:0] state;
	wire state_reset;
	wire [6:0] opcode = instr[6:0];
	wire [2:0] funct3 = instr[14:12];
	wire [6:0] funct7 = instr[31:25];
	wire funct7_bit5 = funct7[5];
	wire funct7_bit0 = funct7[0];
	wire pc_src;

	always @(posedge clk) begin
		if (!resetn) begin
			state <= 0;
		end else begin
			if (en) begin
				if (state_reset)
					state <= 0;
				else
					state <= state + 1;
			end
		end
	end
	
	assign instr_write = en & (state == 1);
	
	assign instr_type = opcode == 7'b0110011 ? RTYPE :
							  opcode == 7'b0010011 ? ITYPE :
							  opcode == 7'b0000011 ? ITYPE :
							  opcode == 7'b0100011 ? STYPE :
							  opcode == 7'b1100011 ? BTYPE :
											7'bx;
											
	wire nop = instr == 32'b0;
											
	decoder md(
		pre_en, en,
		state,
		nop,
		opcode,
		funct3,
		funct7_bit5, funct7_bit0,
		zero, zero_write,
		lt, lt_write,
		result_src,
		pc_write,
		mem_write,
		branch, alu_a_src, alu_b_src,
		addr_src,
		reg_write,
		imm_src,
		alu_op,
		state_reset,
		ar_write, ar_src,
		mem_src,
		loaded_data_write
	);

//	assign pc_src = branch & zero | jump;
endmodule

module decoder(
	input wire pre_en, en,
	input wire [2:0] state,
	input wire nop,
	input wire [6:0] opcode,
	input wire [2:0] funct3,
	input wire funct7_bit5, funct7_bit0,
	input wire zero,
	output reg zero_write,
	input wire lt,
	output reg lt_write,
	output reg [1:0] result_src,
	output reg pc_write,
	output reg mem_write,
	output reg branch,
	output reg [1:0] alu_a_src, alu_b_src,
	output reg addr_src,
	output reg reg_write,
	output wire [1:0] imm_src,
	output reg [3:0] alu_op,
	output reg state_reset,
	output reg ar_write, ar_src,
	output reg mem_src,
	output reg loaded_data_write
);
	`include "control_signals.vh"
	
	// Derived from kmap
	wire operand_is_imm = (~opcode[5] & ~opcode[3] & ~opcode[2] & opcode[1] & opcode[0]) |
												(~opcode[4] & ~opcode[3] & ~opcode[2] & opcode[1] & opcode[0]);
	reg fetching_next_instr;								
//	assign pc_write = state_reset;

	reg jump;
	
	wire equality_check = funct3 == 3'h0 | funct3 == 3'h1;

	always @(*) begin
		result_src = RESULT_SRC_ALU;
		state_reset = 0;
		fetching_next_instr = state_reset;
		reg_write = 0;
		branch = 0;
		jump = 0;
		mem_write = 0;
		addr_src = ADDR_SRC_PC;
		ar_write = 0;
//		pc_write = state_reset;
		pc_write = 0;
		zero_write = 0;
		jump = 0;
		ar_src = AR_SRC_ALU;
		mem_src = SRC_VGA;
		alu_a_src = 2'bxx;
		alu_b_src = 2'bxx;
		loaded_data_write = 0;
		lt_write = 0;
		
		if (pre_en) begin
			mem_src = SRC_CPU;
			
			// This is so fkn scuffed. If we are loading, then we need the value from memory right when we reach state = 1
			// If we don't have this, it will still be fetching the instruction
			if (opcode == 7'b0000011)
				addr_src = ADDR_SRC_AR;
		end
		
//		if(nop)
//			state_reset = 1;
		if (en) begin
			if (state == 0)
				mem_src = SRC_CPU;
			case(opcode)
				7'b0110011: begin // REGISTER ARITHMETIC OPERATIONS (ADD, SUB, SLL, etc)
					result_src = RESULT_SRC_ALU;
					if (state == 1) begin
//						reg_write = 1;
						alu_a_src = ALU_A_SRC_REG;
						alu_b_src = ALU_B_SRC_REG;
						case (funct3)
							3'h0: if(funct7_bit5) begin
								alu_op = ALU_OP_SUB;
							end else if (funct7_bit0) begin
								alu_op = ALU_OP_MUL;
							end else begin
								alu_op = ALU_OP_ADD;
							end
							3'h4: begin
								if (funct7_bit0) begin
									alu_op = ALU_OP_DIV;
								end else begin
									alu_op = ALU_OP_XOR;
								end
							end
							3'h6: alu_op = ALU_OP_OR;
							3'h7: alu_op = ALU_OP_AND;
							3'h1: alu_op = ALU_OP_SLL;
							3'h5: alu_op = ALU_OP_SRL;
							default: alu_op = 3'bxxx;
						endcase
						
						ar_src = AR_SRC_REG_ADDR;
						ar_write = 1;
					end else if (state == 2) begin
						alu_a_src = ALU_A_SRC_REG;
						alu_b_src = ALU_B_SRC_REG;
						reg_write = 1;
						
						mem_write = 1;
						addr_src = ADDR_SRC_AR;
						ar_src= AR_SRC_REG_ADDR;
						mem_src = SRC_CPU;
					end else if (state == 3) begin
						state_reset = 1;
						pc_write = 1;
						alu_op = ALU_OP_ADD; // Calculate next PC
						alu_a_src = ALU_A_SRC_PC;
						alu_b_src = ALU_B_SRC_1;
					end
				end
				7'b0010011: begin // REGISTER IMMEDIATE ARITHMETIC
					result_src = RESULT_SRC_ALU;
					if (state == 1) begin
						alu_a_src = ALU_A_SRC_REG;
						alu_b_src = ALU_B_SRC_IMM;
//						reg_write = 1;
						case (funct3)
							3'h0: alu_op = ALU_OP_ADD;
							3'h4: alu_op = ALU_OP_XOR;
							3'h6: alu_op = ALU_OP_OR;
							3'h7: alu_op = ALU_OP_AND;
							3'h1: alu_op = ALU_OP_SLL;
							3'h5: alu_op = ALU_OP_SRL;
							default: alu_op = 3'bxxx;
						endcase
						
						ar_src = AR_SRC_REG_ADDR;
						ar_write = 1;
					end else if (state == 2) begin
						alu_a_src = ALU_A_SRC_REG;
						alu_b_src = ALU_B_SRC_IMM;
						reg_write = 1;
						
						mem_write = 1;
						addr_src = ADDR_SRC_AR;
						ar_src= AR_SRC_REG_ADDR;
						mem_src = SRC_CPU;
					end else if (state == 3) begin
						state_reset = 1;
						pc_write = 1;
						alu_op = ALU_OP_ADD; // Calculate next PC
						alu_a_src = ALU_A_SRC_PC;
						alu_b_src = ALU_B_SRC_1;
					end
				end
				7'b0000011: begin // LOAD
					if (state == 1) begin
						mem_src = SRC_CPU;
						alu_op = ALU_OP_ADD;
						alu_a_src = ALU_A_SRC_REG;
						alu_b_src = ALU_B_SRC_IMM;
						addr_src = ADDR_SRC_AR;
						ar_write = 1;
					end else if (state == 2) begin
						mem_src = SRC_CPU;
						addr_src = ADDR_SRC_AR;
						reg_write = 1;
						result_src = RESULT_SRC_RD;
						loaded_data_write = 1;
						
						ar_src = AR_SRC_REG_ADDR;
						ar_write = 1;
					end else if (state == 3) begin
						result_src = RESULT_SRC_LOADED;
					
						mem_write = 1;
						addr_src = ADDR_SRC_AR;
						ar_src= AR_SRC_REG_ADDR;
						mem_src = SRC_CPU;
					end else if (state == 4) begin
						state_reset = 1;
						pc_write = 1;
						alu_op = ALU_OP_ADD; // Calculate next PC
						alu_a_src = ALU_A_SRC_PC;
						alu_b_src = ALU_B_SRC_1;
					end
				end
				7'b0100011: begin // STORE
					if (state == 1) begin
						result_src = RESULT_SRC_RD;
						alu_op = ALU_OP_ADD;
						alu_a_src = ALU_A_SRC_REG;
						alu_b_src = ALU_B_SRC_IMM;
						ar_write = 1;
					end else if (state == 2) begin
						mem_write = 1;
						addr_src = ADDR_SRC_AR;
						mem_src = SRC_CPU;
						
						state_reset = 1;
						pc_write = 1;
						alu_op = ALU_OP_ADD; // Calculate next PC
						alu_a_src = ALU_A_SRC_PC;
						alu_b_src = ALU_B_SRC_1;
					end
				end
				7'b1100011: begin // BREAKS
					if (state == 1) begin
						alu_a_src = ALU_A_SRC_REG;
						alu_b_src = ALU_B_SRC_REG;
						if (equality_check) begin
							alu_op = ALU_OP_SUB;
							zero_write = 1;
						end else begin
							alu_op = ALU_OP_LT;
							lt_write = 1;
						end
					end else if (state == 2) begin
						state_reset = 1;
						pc_write = 1;
						alu_op = ALU_OP_ADD;
						alu_a_src = ALU_A_SRC_PC;
						case (funct3)
							3'h0: jump = zero;  // BEQ
							3'h1: jump = ~zero; // BNE
							3'h4: jump = lt;    // BLT
							default: jump = 0;
						endcase
						
						if (jump) begin // Break, so calculate address
							alu_b_src = ALU_B_SRC_IMM;
						end else begin
							alu_b_src = ALU_B_SRC_1;
						end
					end
				end
				default: begin
					alu_op = 3'bxxx;
				end
			endcase
		end
//		else begin
//			mem_src = SRC_CPU;
//		end
	end
endmodule
