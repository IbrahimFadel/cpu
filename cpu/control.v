`include "instrs.vh"

module control(
	input clk, reset,
	input [7:0] instr,
	input [15:0] addr_bus,
	input [7:0] ext_data_bus,
	input [15:0] int_data_bus,
	output [2:0] int_data_bus_sel,
	input [7:0] dst_reg,

	output read, write,
	output ar_load, ir_load,
	output pc_read,
	output [2:0] ar_sel,
	
	output [15:0] r0_data, r1_data, r2_data, r3_data,
	output r0_en, r1_en, r2_en, r3_en, dst_reg_en,
	output r0_ld, r1_ld, r2_ld, r3_ld, dst_reg_ld,
	output [15:0] a_in, b_in,
	output a_ld, b_ld,
	output [15:0] acc_in,
	output acc_ld,
	output [3:0] op_in,
	output pc_inc
);
	reg [3:0] state = 0;

	wire clear_state;

	always @(posedge clk) begin
		if (reset) begin
			state <= 0;
		end else begin
			if (clear_state)
				state <= 0;
			else
				state <= state + 1;
		end
	end

	// Generic
	wire fetch1 = state == 0;
	wire fetch2 = state == 1;

	// MOV_REG_REG
	wire mov_reg_reg1 = (state == 2) && (instr == `MOV_REG_REG);
	wire mov_reg_reg2 = (state == 3) && (instr == `MOV_REG_REG);

	// MOV_REG_LIT
	wire mov_reg_lit1 = (state == 2) && (instr == `MOV_REG_LIT);
	wire mov_reg_lit2 = (state == 3) && (instr == `MOV_REG_LIT);

	// MOV_MEM_REG
	wire mov_mem_reg1 = (state == 2) && (instr == `MOV_MEM_REG);
	wire mov_mem_reg2 = (state == 3) && (instr == `MOV_MEM_REG);
	wire mov_mem_reg3 = (state == 4) && (instr == `MOV_MEM_REG);

	// ADD_REG_LIT
	wire add_reg_lit1 = (state == 2) && (instr == `ADD_REG_LIT);
	wire add_reg_lit2 = (state == 3) && (instr == `ADD_REG_LIT);
	wire add_reg_lit3 = (state == 4) && (instr == `ADD_REG_LIT);

	assign clear_state = mov_reg_reg2 || mov_reg_lit2 || add_reg_lit3;

	assign read = fetch1 || fetch2 ||
								mov_reg_lit1 || mov_reg_lit2 ||
								mov_reg_reg1 ||
								mov_mem_reg1 || mov_mem_reg2 ||
								add_reg_lit1 || add_reg_lit2;
	assign write = mov_mem_reg2;
	assign ar_load = fetch1 || fetch2 ||
									 mov_reg_lit1 || mov_reg_reg1 || mov_mem_reg1 || mov_mem_reg2 ||
									 add_reg_lit1;
	assign ir_load = fetch2;
	assign pc_read = fetch1 || fetch2;
	assign pc_inc = fetch1 || fetch2 || mov_reg_lit1 || mov_reg_reg1 || mov_mem_reg1 || add_reg_lit1;

	assign ar_sel = mov_mem_reg2 ? `AR_READ_DST_REG : `AR_READ_PC;
	assign int_data_bus_sel = mov_mem_reg3 ? `INT_DATA_READ_REG : `INT_DATA_READ_PC;

	// REGISTERS

	wire [15:0] register_src;
	register_src reg_data_src(
		ext_data_bus,
		r0_data,
		r1_data,
		r2_data,
		r3_data,
		int_data_bus,
		register_src
	);

	assign r0_data = mov_reg_lit2 ? ext_data_bus :
									 mov_reg_reg2 ? register_src :
									 int_data_bus;
	assign r1_data = mov_reg_lit2 ? ext_data_bus :
									 mov_reg_reg2 ? register_src :
									 int_data_bus;
	assign r2_data = mov_reg_lit2 ? ext_data_bus : 
									 mov_reg_reg2 ? register_src :
									 int_data_bus;
	assign r3_data = mov_reg_lit2 ? ext_data_bus :
									 mov_reg_reg2 ? register_src :
									 int_data_bus;

	assign dst_reg_ld = mov_reg_lit1 || mov_reg_reg1 || mov_mem_reg1;

	wire reg_ld = mov_reg_lit2 || mov_reg_reg2;
	assign r0_ld = reg_ld && dst_reg == `R0;
	assign r1_ld = reg_ld && dst_reg == `R1;
	assign r2_ld = reg_ld && dst_reg == `R2;
	assign r3_ld = reg_ld && dst_reg == `R3;

	wire reg_en = mov_reg_reg2 || mov_mem_reg3 || add_reg_lit1;
	wire [7:0] src_reg = ext_data_bus;
	assign r0_en = reg_en && (src_reg == `R0);
	assign r1_en = reg_en && (src_reg == `R1);
	assign r2_en = reg_en && (src_reg == `R2);
	assign r3_en = reg_en && (src_reg == `R3);

	assign a_ld = add_reg_lit1;
	assign b_ld = add_reg_lit2;

	assign a_in = r0_en ? r0_data :
								r1_en ? r1_data :
								r2_en ? r2_data :
								r3_en ? r3_data :
								{(16){1'bz}};

	wire load_from_ext = add_reg_lit2;
	assign b_in = load_from_ext ? ext_data_bus :
								{(16){1'bz}};

	assign op_in = (add_reg_lit1 || add_reg_lit2 || add_reg_lit3) ? `OP_ADD : {(4){1'bz}};

	assign acc_ld = add_reg_lit3;
endmodule

module register_src(
	input [7:0] register,
	input [15:0] r0, r1, r2, r3,
	input [15:0] default_src,
	output [15:0] out
);
	assign out = register == `R0 ? r0 :
							 register == `R1 ? r1 :
							 register == `R2 ? r2 :
							 register == `R3 ? r3 :
							 default_src;
endmodule