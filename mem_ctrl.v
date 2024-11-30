module mem_ctrl #(`include "parameters.vh") (
	input wire clk, resetn,
	input wire [WORD_SIZE-1:0] cpu_addr,
	input wire [8:0] vga_addr,
	input wire [WORD_SIZE-1:0] cpu_wd,
	input wire cpu_we,
	input wire src,
	output wire [WORD_SIZE-1:0] rd
);
	`include "control_signals.vh"
	
	wire [WORD_SIZE-1:0] addr = src == SRC_CPU ? cpu_addr : {23'b0, vga_addr};
	wire we = src == SRC_CPU ? cpu_we : 0;
	wire [WORD_SIZE-1:0] wd = src == SRC_CPU ? cpu_wd : {WORD_SIZE{1'bz}};

	ram512x32 onchip_ram(
		addr, clk, wd, we, rd
	);
endmodule

//module mem_ctrl #(`include "parameters.vh") (
//	input wire clk, resetn,
//	input wire [WORD_SIZE-1:0] cpu_addr,
//	input wire [8:0] vga_addr,
//	input wire [WORD_SIZE-1:0] cpu_wd,
//	input wire cpu_we,
//	input wire src,
//	output wire [WORD_SIZE-1:0] rd
//);
//	`include "control_signals.vh"
	
//	wire [WORD_SIZE-1:0] addr = src == SRC_CPU ? cpu_addr : {23'b0, vga_addr};
//	wire we = src == SRC_CPU ? cpu_we : 0;
//	wire [WORD_SIZE-1:0] wd = src == SRC_CPU ? cpu_wd : {WORD_SIZE{1'bz}};

//	ram512x32 onchip_ram(
//		addr[8:0], clk, wd, we, rd
//	);
//endmodule

//
//module mem_ctrl #(`include "parameters.vh") (
//	input wire clk, resetn,
//	input wire [WORD_SIZE-1:0] addr,
//	input wire [WORD_SIZE-1:0] wd,
//	input wire we,
//	output wire [WORD_SIZE-1:0] rd
//);
//	ram512x32 onchip_ram(
//		addr, clk, wd, we, rd
//	);
//endmodule
