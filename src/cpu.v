module cpu(
	input wire clk, reset,
	output wire [31:0] PC,
	input wire [31:0] Instr,
	output wire MemWrite,
	output wire [31:0] ALUResult, WriteData,
	input wire [31:0] ReadData
);
	wire ALUSrc, RegWrite, Jump, Zero;
	wire [1:0] ResultSrc, ImmSrc;
	wire [2:0] ALUControl;

	// controller c();
	// datapath dp();	
endmodule
