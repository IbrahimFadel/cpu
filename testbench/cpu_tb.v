`timescale 1ns/1ns

`include "signals.vh"
`include "sizes.vh"
`include "instrs.vh"
`include "registers.vh"

module cpu_tb;
	reg clk = 0;
	reg reset;

	wire [`WORD_SIZE-1:0] addr_bus;
	wire [7:0] data_bus;
	reg [7:0] data_bus_drive;

	wire rom_en, ram_en;
	wire read_en, write_en;

	addr_decoder addr_decoder(
		.addr(addr_bus),
		.rom_en(rom_en),
		.ram_en(ram_en)
	);

	reg [`BYTE_SIZE-1:0] rom [`ROM_SIZE-1:0];
	reg [`BYTE_SIZE-1:0] ram [`RAM_SIZE-1:0];

	integer i;
	initial begin
    for(i = 0; i < `ROM_SIZE; i = i + 1 ) begin
        rom[i] = 0;
    end
		for(i = 0; i < `RAM_SIZE; i = i + 1 ) begin
        ram[i] = 0;
    end

		rom[0] = `MOV_REG_LIT;
		rom[1] = `R0;
		rom[2] = 64;
		rom[3] = `ADD_REG_LIT;
		rom[4] = `R0;
		rom[5] = 10;
		rom[6] = `MOV_MEM_REG;
		rom[7] = 100; // Address
		rom[8] = `R0;
	end

	cpu c(
		.clk(clk),
		.reset(reset),
		.addr_bus(addr_bus),
		.ext_data_bus(data_bus),
		.read_en(read_en),
		.write_en(write_en)
	);

	always #5 clk = !clk;
	
	initial begin
		$dumpfile("cpu_tb.vcd");
		$dumpvars(0, cpu_tb);

		$display("Testing CPU");
		$monitor("addr_bus = %h, data_bus = %h", addr_bus, data_bus);

		reset = `YES_RESET;
		#10
		reset = `NO_RESET;
		#150 $finish;
	end



	assign data_bus = read_en ? data_bus_drive : {(`WORD_SIZE){1'bz}};
	always @(posedge clk) begin
		if (rom_en) begin
			if (read_en) begin
				data_bus_drive <= rom[addr_bus];
			end
		end else if (ram_en) begin
			if (read_en) begin
				data_bus_drive <= ram[addr_bus];
			end else if (write_en) begin
				ram[addr_bus] <= data_bus_drive;
			end
		end
	end

endmodule
