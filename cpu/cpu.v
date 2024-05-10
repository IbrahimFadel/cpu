`include "signals.vh"
`include "sizes.vh"

module cpu #(
		parameter WORD_SIZE=`WORD_SIZE
	) (
		input clk, reset,
		output [WORD_SIZE-1:0] addr_bus,
		inout [7:0] ext_data_bus,
		output read_en, write_en
	);
	wire [WORD_SIZE-1:0] int_data_bus;

	wire pc_inc;
	wire [WORD_SIZE-1:0] pc_out;
	pc_reg pc(
		.clk(clk),
		.reset(reset),
		.inc(pc_inc),
		.out(pc_out)
	);

	wire [2:0] int_data_bus_sel;
	wire [2:0] ar_sel;
	wire ar_load;

	wire ir_load;
	wire [7:0] ir_in, ir_out;
	ir_reg ir(
		.clk(clk),
		.reset(reset),
		.in(ir_in),
		.load(ir_load),
		.out(ir_out)
	);
	assign ir_in = ir_load ? ext_data_bus : {(WORD_SIZE){1'bz}};

	wire [WORD_SIZE-1:0] r0_data, r1_data, r2_data, r3_data;
	wire r0_ld, r1_ld, r2_ld, r3_ld, dst_reg_ld;
	wire r0_en, r1_en, r2_en, r3_en, dst_reg_en;

	gp_reg r0(
		.clk(clk),
		.reset(reset),
		.data(r0_data),
		.load(r0_ld),
		.enable(r0_en)
	);
	gp_reg r1(
		.clk(clk),
		.reset(reset),
		.data(r1_data),
		.load(r1_ld),
		.enable(r1_en)
	);
	gp_reg r2(
		.clk(clk),
		.reset(reset),
		.data(r2_data),
		.load(r2_ld),
		.enable(r2_en)
	);
	gp_reg r3(
		.clk(clk),
		.reset(reset),
		.data(r3_data),
		.load(r3_ld),
		.enable(r3_en)
	);

	wire [7:0] dst_reg_out;
	dst_reg dst_reg(
		.clk(clk),
		.reset(reset),
		.in(ext_data_bus),
		.load(dst_reg_ld),
		.out(dst_reg_out)
	);

	wire a_ld, b_ld;
	wire [WORD_SIZE-1:0] a_in, b_in, a_out, b_out;
	alu_reg a(
		.clk(clk),
		.reset(reset),
		.in(a_in),
		.load(a_ld),
		.out(a_out)
	);
	alu_reg b(
		.clk(clk),
		.reset(reset),
		.in(b_in),
		.load(b_ld),
		.out(b_out)
	);

	wire acc_ld;
	wire [WORD_SIZE-1:0] acc_in, acc_out;
	acc_reg acc(
		.clk(clk),
		.reset(reset),
		.in(acc_in),
		.load(acc_ld),
		.out(acc_out)
	);

	wire [3:0] op_in;
	alu alu(
		.a(a_out),
		.b(b_out),
		.op(op_in),
		.alu_out(acc_in)
	);

	wire clear;
	wire pc_read;
	control ctrl(
		.clk(clk),
		.reset(reset),
		.instr(ir_out),
		.ext_data_bus(ext_data_bus),
		.int_data_bus(int_data_bus),
		.int_data_bus_sel(int_data_bus_sel),
		.read(read_en), .write(write_en),
		.ar_load(ar_load), .ir_load(ir_load),
		.pc_read(pc_read),
		.ar_sel(ar_sel),
		.dst_reg(dst_reg_out),
		.r0_data(r0_data), .r1_data(r1_data), .r2_data(r2_data), .r3_data(r3_data),
		.r0_en(r0_en), .r1_en(r1_en), .r2_en(r2_en), .r3_en(r3_en), .dst_reg_en(dst_reg_en),
		.r0_ld(r0_ld), .r1_ld(r1_ld), .r2_ld(r2_ld), .r3_ld(r3_ld), .dst_reg_ld(dst_reg_ld),
		.a_in(a_in), .b_in(b_in),
		.a_ld(a_ld), .b_ld(b_ld),
		.acc_in(acc_in),
		.acc_ld(acc_ld),
		.op_in(op_in),
		.pc_inc(pc_inc)
	);

	wire [15:0] reg_out;
	reg_mux reg_mux(
		.register(ext_data_bus),
		.r0(r0_data), .r1(r1_data), .r2(r2_data), .r3(r3_data),
		.out(reg_out)
	);

	wire [15:0] int_data_read_bus = int_data_bus_sel == `INT_DATA_READ_PC ? pc_out :
																	int_data_bus_sel == `INT_DATA_READ_REG ? reg_out :
																	{(WORD_SIZE){1'bz}};
	// assign int_data_bus = int_data_read_bus;
	assign int_data_bus = pc_read ? pc_out : 
												{(WORD_SIZE){1'bz}};

	wire [15:0] ar_read_bus = ar_sel == `AR_READ_PC ? pc_out :
														ar_sel == `AR_READ_DST_REG ? dst_reg_out :
														{(WORD_SIZE){1'bz}};
	assign addr_bus = ar_load ? ar_read_bus : {(WORD_SIZE){1'bz}};

endmodule