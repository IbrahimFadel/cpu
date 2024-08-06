`include "sizes.vh"

module addr_decoder #(
		parameter WORD_SIZE=`WORD_SIZE
	) (
		input [WORD_SIZE-1:0] addr,
		output rom_en, ram_en
	);
	// 0-255 ROM
	// 255-512 RAM
	assign rom_en = ~addr[WORD_SIZE-1];
	assign ram_en = addr[WORD_SIZE-1];
endmodule