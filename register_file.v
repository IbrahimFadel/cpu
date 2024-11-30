module register_file #(`include "parameters.vh") (
	input wire clk, resetn,
	input wire [4:0] A1, A2, A3,
	input wire [WORD_SIZE-1:0] WD3,
	input wire we,
	output wire [WORD_SIZE-1:0] RD1, RD2
);
	reg [WORD_SIZE-1:0] registers[NUM_REG-1:0];
//	integer i;

	always @(posedge clk) begin
		if (!resetn) begin
			registers[0] <= 0;
			registers[1] <= 0;
			registers[2] <= 127;
			registers[3] <= 0;
			registers[4] <= 0;
			registers[5] <= 0;
			registers[6] <= 0;
			registers[7] <= 0;
			registers[8] <= 0;
			registers[9] <= 0;
			registers[10] <= 0;
			registers[11] <= 0;
			registers[12] <= 0;
			registers[13] <= 0;
			registers[14] <= 0;
			registers[15] <= 0;
			registers[16] <= 0;
			registers[17] <= 0;
			registers[18] <= 0;
			registers[19] <= 0;
			registers[20] <= 0;
			registers[21] <= 0;
			registers[22] <= 0;
			registers[23] <= 0;
			registers[24] <= 0;
			registers[25] <= 0;
			registers[26] <= 0;
			registers[27] <= 0;
			registers[28] <= 0;
			registers[29] <= 0;
			registers[30] <= 0;
			registers[31] <= 0;
//			for (i = 0; i < NUM_REG; i = i + 1) begin
//				if (i == 2) begin
//					registers[i] <= 127; // Initialize Stack Pointer
//				end else begin
//					registers[i] <= {{WORD_SIZE}{1'b0}};
//				end
//			end
		end else begin
			if (we) begin
				registers[A3] <= WD3;
			end
		end
	end

	// x0 is hardwired to 0
	assign RD1 = A1 == 0 ? {{WORD_SIZE}{1'b0}} : registers[A1];
	assign RD2 = A2 == 0 ? {{WORD_SIZE}{1'b0}} : registers[A2];
endmodule
