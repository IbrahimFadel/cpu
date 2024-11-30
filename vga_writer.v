module vga_writer(CLOCK_50, KEY, addr, register_value, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, finished_register);
	input CLOCK_50;
	input [3:0] KEY;
	output [8:0] addr;
	input  [31:0] register_value;
	output finished_register;
	
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;
	wire [8:0] VGA_X;
	wire [7:0] VGA_Y;
	wire [2:0] VGA_COLOR;
	
		wire [8:0] test;
	assign addr = test;
	
	vga u1(CLOCK_50, KEY[0], VGA_X, VGA_Y, VGA_COLOR, test, register_value, finished_register);
	vga_adapter ADAPTER_INST(KEY[0], CLOCK_50, VGA_COLOR, VGA_X, VGA_Y, KEY[3], VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYN_N, VGA_CLK);
	defparam ADAPTER_INST.RESOLUTION = "320x240";
	defparam ADAPTER_INST.MONOCHROME = "FALSE";
	defparam ADAPTER_INST.BITS_PER_COLOUR_CHANNEL = 1;
	
endmodule

module vga(clk, resetn, X_COORD, Y_COORD, COLOR, addr, register_value, finished_register);
	input wire clk, resetn;
	output [8:0] X_COORD;
	output [7:0] Y_COORD;
	output [2:0] COLOR;
	output [8:0] addr;
	input  [31:0] register_value;
	output finished_register;
	
	localparam SPACE = 127; // can use this if you ever want to display a space
	parameter MIF_REG_OFFSET = 'h1E0;
	
	// hardcoded x coordinates array
	reg [7:0] x_coords [0:12];
	initial begin
		x_coords[0] = 2;
		x_coords[1] = 13;
		x_coords[2] = 24;
		x_coords[3] = 35;
		x_coords[4] = 46;
		x_coords[5] = 57;
		x_coords[6] = 68;
		x_coords[7] = 79;
		x_coords[8] = 90;
		x_coords[9] = 101;
		x_coords[10] = 112;
		x_coords[11] = 123;
		x_coords[12] = 134;
	end
	
	reg [7:0] y_coords [0:15];
	initial begin
		y_coords[0] = 0;
		y_coords[1] = 15;
		y_coords[2] = 30;
		y_coords[3] = 45;
		y_coords[4] = 60;
		y_coords[5] = 75;
		y_coords[6] = 90;
		y_coords[7] = 105;
		y_coords[8] = 120;
		y_coords[9] = 135;
		y_coords[10] = 150;
		y_coords[11] = 165;
		y_coords[12] = 180;
		y_coords[13] = 195;
		y_coords[14] = 210;
		y_coords[15] = 225;
	end

	
	wire [5:0] n; // counts 0-63 since there are 64 pixels are in each 8x8 character
	
	reg [2:0] bitmap_x, bitmap_y; // iterate through each pixel in a given character bitmap
		
	wire plotted_character = (n == 63); // goes high once a full character has been plotted
	
	full_char_counter fcc(clk, resetn, n);
	
	wire [4:0] register_idx; // keeps track of how many registers were displayed
	wire [4:0] y;

	// (0, 0) -> (11, 3)
	// counts through each 12 characters, 3 times
	// is only enabled if a character is plotted (since we can only do 1 pixel out of 64 per clock cycle)
	wire [3:0] x;
	wire column;
	indices_counter cc (clk, resetn, plotted_character, x, y, column, register_idx, finished_register);

	// setting coordinate of first pixel
	wire [9:0] x_coord = x_coords[x] + (column * 176);
	wire [8:0] y_coord = y_coords[y];

	// iterate through the bitmap pixel by pixel, left to right, top to bottom
	always @(posedge clk) begin
		if (!resetn) begin
			bitmap_x <= 0;
			bitmap_y <= 0;
		end else begin
			if (bitmap_x == 7) begin
				bitmap_x <= 0;
				if (bitmap_y == 7)
					bitmap_y <= 0;
				else begin
					bitmap_y <= bitmap_y + 1;
				end
			end else begin
				bitmap_x <= bitmap_x + 1;
			end
		end
	end

	wire [31:0] register_value;
	// wire [8:0] addr;
	assign addr = register_idx;
	// ram512x32 mifr1 (addr, clk, 32'b0, 1'b0, register_value);
	
	// extracting each digit from a register value and placing it in a digits array
	wire [6:0] digits [12:0];
	assign digits[12] = register_value[3:0];
	assign digits[11] = register_value[7:4];
	assign digits[10] = register_value[11:8];
	assign digits[9] = register_value[15:12];
	assign digits[8] = register_value[19:16];
	assign digits[7] = register_value[23:20];
	assign digits[6] = register_value[27:24];
	assign digits[5] = register_value[31:28];
	assign digits[4] = SPACE; // hardcoded to space (null bitmap)
	assign digits[3] = 58; // hardcoded to colon
	assign digits[2] = register_idx[3:0];
	assign digits[1] = register_idx[4]; // number of the register being displayed
	assign digits[0] = 88; // hardcoded to x

	// character from the digits array being traversed by the horizontal counter index
	wire [7:0] digit = digits[x];
	
	// mapping a character to its bitmap row by row
	wire [63:0] pixelLine;
	char_bitmap bmp1(digit, pixelLine);
	wire[7:0] pixels [7:0];
	assign pixels[0] = pixelLine[7:0];
	assign pixels[1] = pixelLine[15:8];
	assign pixels[2] = pixelLine[23:16];
	assign pixels[3] = pixelLine[31:24];
	assign pixels[4] = pixelLine[39:32];
	assign pixels[5] = pixelLine[47:40];
	assign pixels[6] = pixelLine[55:48];
	assign pixels[7] = pixelLine[63:56];

	// assigning coordinates for the vga adapter
	assign X_COORD = x_coord + bitmap_x;
	assign Y_COORD = y_coord + bitmap_y;

	// if x is less than 4 (i.e. still displaying the register name) display in green. if displaying the register value, display in white. otherwise black
	assign COLOR = (pixels[bitmap_y][7-bitmap_x]) ? (x < 4 ? 3'b010 : 3'b111) : 3'b0;
endmodule

// standard counter that counts 0-63 (counts through all the pixels of an individual 8x8 character)
module full_char_counter (clk, resetn, n);
	input wire clk, resetn;
	output reg [5:0] n;
	always @(posedge clk) begin
		if (!resetn) begin
			n <= 0;
		end else begin
			if (n == 63)
				n <= 0;
			else
				n <= n + 1;
		end
	end
endmodule

// iterate through the register characters. once x reaches the last character, increment y to the next row and start over again
module indices_counter (clk, resetn, en, x, y, column, register_idx, finished_register);
	input wire clk, resetn, en;
	output reg [3:0] x;
	output reg [4:0] y;
	output reg [4:0] register_idx;
	output reg column;
	output reg finished_register;
	
	always @(posedge clk) begin
		if (!resetn) begin
			x <= 0;
			y <= 0;
			column <= 0;
			register_idx <= 0;
			finished_register <= 0;
		end else begin
			finished_register = 0;
			if (en) begin
				if (x == 12) 
				begin
					finished_register = 1;
					x <= 0;
					if (y == 15) 
					begin
						y <= 0;
						column <= ~column;
					end
					else
					begin
						y <= y + 1;
					end
					if (register_idx == 31)
						register_idx <= 0;
					else
						register_idx <= register_idx + 1;
				end
				else begin
					x <= x + 1;
				end
			end
		end
	end
endmodule


// 8x8 character bitmap for characters space, 0-9, A-F, x and :
module char_bitmap(digit, pixelLine);
	input [7:0] digit;
	output [63:0] pixelLine;
	reg [7:0] pixels [7:0];
	
	assign pixelLine[7:0] = pixels[0];
	assign pixelLine[15:8] = pixels[1];
	assign pixelLine[23:16] = pixels[2];
	assign pixelLine[31:24] = pixels[3];
	assign pixelLine[39:32] = pixels[4];
	assign pixelLine[47:40] = pixels[5];
	assign pixelLine[55:48] = pixels[6];
	assign pixelLine[63:56] = pixels[7];
	
	always @(*) begin
		case(digit[7:0])
				 0: begin // 0
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01111100;
					pixels[2] = 8'b10000110;
					pixels[3] = 8'b10001010;
					pixels[4] = 8'b10010010;
					pixels[5] = 8'b10100010;
					pixels[6] = 8'b11000010;
					pixels[7] = 8'b01111100;
				 end
				 1: begin // 1
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01110000;
					pixels[2] = 8'b01010000;
					pixels[3] = 8'b00010000;
					pixels[4] = 8'b00010000;
					pixels[5] = 8'b00010000;
					pixels[6] = 8'b00010000;
					pixels[7] = 8'b11111110;
				 end
				 2: begin// 2
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01111000;
					pixels[2] = 8'b10000100;
					pixels[3] = 8'b00000100;
					pixels[4] = 8'b00001000;
					pixels[5] = 8'b00010000;
					pixels[6] = 8'b00100000;
					pixels[7] = 8'b01111100;
				 end
				 3: begin // 3
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b11111100;
					pixels[2] = 8'b00000010;
					pixels[3] = 8'b00000010;
					pixels[4] = 8'b00111100;
					pixels[5] = 8'b00000010;
					pixels[6] = 8'b00000010;
					pixels[7] = 8'b11111100;
				 end
				 4: begin // 4
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b10001000;
					pixels[2] = 8'b10001000;
					pixels[3] = 8'b10001000;
					pixels[4] = 8'b11111110;
					pixels[5] = 8'b00001000;
					pixels[6] = 8'b00001000;
					pixels[7] = 8'b00001000;
				 end
				 5: begin // 5
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b11111110;
					pixels[2] = 8'b10000000;
					pixels[3] = 8'b10000000;
					pixels[4] = 8'b11111100;
					pixels[5] = 8'b00000010;
					pixels[6] = 8'b00000010;
					pixels[7] = 8'b11111100;
				 end
				 6: begin // 6
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01111100;
					pixels[2] = 8'b10000000;
					pixels[3] = 8'b10000000;
					pixels[4] = 8'b11111100;
					pixels[5] = 8'b10000010;
					pixels[6] = 8'b10000010;
					pixels[7] = 8'b01111100;
				 end
				 7: begin // 7
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b11111110;
					pixels[2] = 8'b00000010;
					pixels[3] = 8'b00000100;
					pixels[4] = 8'b00001000;
					pixels[5] = 8'b00010000;
					pixels[6] = 8'b00100000;
					pixels[7] = 8'b01000000;
				 end
				 8: begin // 8
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01111100;
					pixels[2] = 8'b10000010;
					pixels[3] = 8'b10000010;
					pixels[4] = 8'b01111100;
					pixels[5] = 8'b10000010;
					pixels[6] = 8'b10000010;
					pixels[7] = 8'b01111100;
				 end
				 9: begin // 9
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01111100;
					pixels[2] = 8'b10000010;
					pixels[3] = 8'b10000010;
					pixels[4] = 8'b01111110;
					pixels[5] = 8'b00000010;
					pixels[6] = 8'b00000010;
					pixels[7] = 8'b00000010;
				end
				10: begin // A
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01111000;
					pixels[2] = 8'b10000100;
					pixels[3] = 8'b10000100;
					pixels[4] = 8'b11111100;
					pixels[5] = 8'b10000100;
					pixels[6] = 8'b10000100;
					pixels[7] = 8'b10000100;
				 end
				 11: begin // B
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b11110000;
					pixels[2] = 8'b10001000;
					pixels[3] = 8'b10001000;
					pixels[4] = 8'b11111000;
					pixels[5] = 8'b10000100;
					pixels[6] = 8'b10000100;
					pixels[7] = 8'b11111000;
				 end
				 12: begin // C
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01111110;
					pixels[2] = 8'b10000000;
					pixels[3] = 8'b10000000;
					pixels[4] = 8'b10000000;
					pixels[5] = 8'b10000000;
					pixels[6] = 8'b10000000;
					pixels[7] = 8'b01111110;
				 end
				 13: begin // D
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b11111000;
					pixels[2] = 8'b10000100;
					pixels[3] = 8'b10000100;
					pixels[4] = 8'b10000100;
					pixels[5] = 8'b10000100;
					pixels[6] = 8'b10000100;
					pixels[7] = 8'b11111000;
				 end
				 14: begin // E
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b11111110;
					pixels[2] = 8'b10000000;
					pixels[3] = 8'b10000000;
					pixels[4] = 8'b11111100;
					pixels[5] = 8'b10000000;
					pixels[6] = 8'b10000000;
					pixels[7] = 8'b11111110;
				 end
				 15: begin // F
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b11111110;
					pixels[2] = 8'b10000000;
					pixels[3] = 8'b10000000;
					pixels[4] = 8'b11111100;
					pixels[5] = 8'b10000000;
					pixels[6] = 8'b10000000;
					pixels[7] = 8'b10000000;
				end
				58: begin //:
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b01100000;
					pixels[2] = 8'b01100000;
					pixels[3] = 8'b00000000;
					pixels[4] = 8'b00000000;
					pixels[5] = 8'b01100000;
					pixels[6] = 8'b01100000;
					pixels[7] = 8'b00000000;					
				end
				88: begin // x
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b10000010;
					pixels[2] = 8'b01000100;
					pixels[3] = 8'b00101000;
					pixels[4] = 8'b00010000;
					pixels[5] = 8'b00101000;
					pixels[6] = 8'b01000100;
					pixels[7] = 8'b10000010;
				end
				default: begin // space (null char)
					pixels[0] = 8'b00000000;
					pixels[1] = 8'b00000000;
					pixels[2] = 8'b00000000;
					pixels[3] = 8'b00000000;
					pixels[4] = 8'b00000000;
					pixels[5] = 8'b00000000;
					pixels[6] = 8'b00000000;
					pixels[7] = 8'b00000000;
				 end
		endcase
	end
endmodule
