`include "global.vh"

module control #(
		parameter BYTE_SIZE=8,
		parameter WORD_SIZE=16
) (
	input wire clk, reset,
	input wire [BYTE_SIZE-1:0] ext_data_bus,
	output wire read_en,
	input wire [BYTE_SIZE-1:0] instr,
	output wire pc_inc, ir_ld, ar_ld,
	output wire r0_ld, r1_ld,
	output wire r0_en, r1_en,
	output wire [WORD_SIZE-1:0] r0, r1,
	input wire [WORD_SIZE-1:0] ar,
	output wire ar_en
);
	reg [3:0] state = 0;
	reg reset_last_cycle;
	wire clear_state;
	
	always @(posedge clk) begin
		if (reset == `RESET) begin
			state <= 0;
			reset_last_cycle <= 1;
		end else if (reset_last_cycle) begin
			state <= 0;
			reset_last_cycle <= 0;
		end else begin
			if (clear_state)
				state <= 0;
			else
				state <= state + 1;
		end
	end

	clear_state_ctrl clear_state_ctrl_u1 (
		.state(state),
		.instr(instr),
		.clear_state(clear_state)
	);

	read_ctrl read_ctrl_u1 (
		.state(state),
		.instr(instr),
		.read_en(read_en)
	);

	pc_ctrl pc_ctrl_u1 (
		.state(state),
		.instr(instr),
		.pc_inc(pc_inc)
	);

	ir_ctrl ir_ctrl_u1 (
		.state(state),
		.ir_ld(ir_ld)
	);

	ar_ctrl ar_ctrl_u1 (
		.state(state),
		.instr(instr),
		.ar_ld(ar_ld),
		.ar_en(ar_en)
	);

	gp_reg_ctrl gp_reg_ctrl_u1 (
		.state(state),
		.instr(instr),
		.ext_data_bus(ext_data_bus),
		.r0_ld(r0_ld), .r1_ld(r1_ld),
		.r0_en(r0_en), .r1_en(r1_en),
		.r0(r0), .r1(r1),
		.ar(ar)
	);
endmodule

module read_ctrl(
	input wire [3:0] state,
	input wire [7:0] instr,
	output wire read_en
);
	wire fetch = state == 0;

	wire instr_read = (instr == `MOV_REG_LIT) & (state == 1 | state == 2) |
										(instr == `ADD_REG_LIT) & (state == 1 | state == 2);

	assign read_en = fetch | instr_read;
endmodule

module clear_state_ctrl (
	input wire [3:0] state,
	input wire [7:0] instr,
	output wire clear_state
);
	wire fetching = state == 1;

	wire last_state = (instr == `MOV_REG_LIT) & (state == 2);

	assign clear_state = ~fetching && last_state;
endmodule

module pc_ctrl (
	input wire [3:0] state,
	input wire [7:0] instr,
	output wire pc_inc
);
	// wire fetch1 = state == 0;
	// wire fetch2 = state == 1;
	// assign pc_inc = fetch1 | fetch2;
	assign pc_inc = 1;
endmodule

module ir_ctrl (
	input wire [3:0] state,
	output wire ir_ld
);
	wire fetch = state == 0;
	assign ir_ld = fetch;
endmodule

module ar_ctrl (
	input wire [3:0] state,
	input wire [7:0] instr,
	output wire ar_ld, ar_en
);
	assign ar_ld = (instr == `MOV_REG_LIT) & (state == 1) |
								 (instr == `ADD_REG_LIT) & (state == 1);
	assign ar_en = (instr == `MOV_REG_LIT) & (state == 2) |
								 (instr == `ADD_REG_LIT) & (state == 2);
endmodule

module gp_reg_ctrl #(
	parameter BYTE_SIZE=8,
	parameter WORD_SIZE=16
) (
	input wire [3:0] state,
	input wire [7:0] instr,
	input wire [BYTE_SIZE-1:0] ext_data_bus,
	output wire r0_ld, r1_ld,
	output wire r0_en, r1_en,
	output [WORD_SIZE-1:0] r0, r1,
	input wire [WORD_SIZE-1:0] ar
);
	wire load_reg = (instr == `MOV_REG_LIT) & (state == 2) |
									(instr == `ADD_REG_LIT) & (state == 1);

	wire [BYTE_SIZE-1:0] src = ((instr == `MOV_REG_LIT) & (state == 2)) ? ext_data_bus : {(BYTE_SIZE){1'bz}};

	wire [WORD_SIZE-1:0] dst = ar;

	assign r0_ld = load_reg & (dst == `R0);
	assign r1_ld = load_reg & (dst == `R1);

	// TODO: change this, cant always be enabled
	assign r0_en = ~r0_ld;
	assign r1_en = ~r1_ld;

	assign r0 = r0_ld ? src : {(WORD_SIZE){1'bz}};
	assign r1 = r1_ld ? src : {(WORD_SIZE){1'bz}};
endmodule

module alu_ctrl (
);
endmodule
