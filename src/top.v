module top(
	input wire clk, reset,
	output wire [31:0] WriteData, DataAddr,
	output wire MemWrite
);
	wire [31:0] PC, Instr, ReadData;
	// instantiate processor and memories
	cpu cpu(clk, reset, PC, Instr, MemWrite, DataAdr, WriteData, ReadData);
	// imem imem(PC, Instr);
	// dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule
