module cpu #(
		parameter WORD_SIZE=16
) (
		input clk, reset,
		output [WORD_SIZE-1:0] addr_bus,
		inout [7:0] ext_data_bus,
		output read_en, write_en
);
	//	########################
	//	#				Registers			 #
	//	########################
	wire [WORD_SIZE-1:0] r0_data, r1_data, pc, ar_data;
	wire [7:0] instr;
	wire r0_ld, r1_ld, pc_ld, ir_ld, ar_ld;
	wire r0_en, r1_en, pc_en,        ar_en;
	wire pc_inc;

	register r0 (
		.clk(clk), .reset(reset),
		.data(r0_data),
		.load(r0_ld), .enable(r0_en)
	);
	register r1 (
		.clk(clk), .reset(reset),
		.data(r1_data),
		.load(r1_ld), .enable(r1_en)
	);
	pc_reg pc_reg (
		.clk(clk), .reset(reset),
		.inc(pc_inc),
		.out(pc)
	);
	ir_reg ir (
		.clk(clk), .reset(reset),
		.in(ext_data_bus),
		.load(ir_ld),
		.out(instr)
	);
	register ar (
		.clk(clk), .reset(reset),
		.data(ar_data),
		.load(ar_ld), .enable(ar_en)
	);
	assign ar_data = ~ar_en ? ext_data_bus : {(WORD_SIZE){1'bz}};

	//	########################
	//	#				Control	  		 #
	//	########################

	control u1 (
		.clk(clk), .reset(reset),
		.ext_data_bus(ext_data_bus),
		.read_en(read_en),
		.instr(instr),
		.pc_inc(pc_inc),
		.ir_ld(ir_ld),
		.ar_ld(ar_ld),
		.r0_ld(r0_ld), .r1_ld(r1_ld),
		.r0_en(r0_en), .r1_en(r1_en),
		.r0(r0_data), .r1(r1_data),
		.ar(ar_data), .ar_en(ar_en)
	);

	assign write_en = 1'bz;

	wire [WORD_SIZE-1:0] addr_bus_read_bus = pc;
	assign addr_bus = addr_bus_read_bus;

endmodule
