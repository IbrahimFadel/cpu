module top #(`include "parameters.vh") (
	input wire CLOCK_50,
	input wire [9:0] SW,
	input wire [3:0] KEY,
	output wire [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0,
	output wire [9:0] LEDR,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_HS,
	output VGA_VS,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	output VGA_CLK
);
	`include "control_signals.vh"
	
	//assign LEDR = SW;
	//assign LEDR[0] = KEY[0];
	
	wire clk = CLOCK_50;
	wire resetn = KEY[0];
//	reg pre_en, en;

	wire pre_en, en;
	slow_clock sc (
		clk, resetn,
		pre_en, en
	);

	wire [WORD_SIZE-1:0] cpu_addr;
	wire [WORD_SIZE-1:0] read_data;
	wire cpu_we;
	wire [WORD_SIZE-1:0] cpu_wd;
	wire mem_src;
	
	wire [8:0] vga_addr;
	
	assign LEDR[8:0] = vga_addr;
	
//	assign vga_addr = 127 - (SW * 4);
//	assign vga_addr = SW[8:0];
//	assign vga_addr = 95;
//	assign vga_addr = 1;
	// assign vga_addr = 127 - (SW * 2);

	wire [WORD_SIZE-1:0] A3, WD3;
	wire reg_write;
	reg [WORD_SIZE-1:0] registers [0:31];
	
	wire [WORD_SIZE-1:0] x1 = registers[vga_addr];
	
	integer i;
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
//			x1 <= 0;
//			for (i = 0; i < 32; i = i + 1) begin
//				if (i == 2) begin
//					registers[i] <= 127; // Initialize Stack Pointer
//				end else begin
//					registers[i] <= {{WORD_SIZE}{1'b0}};
//				end
//			end
		end else begin
			if (reg_write) begin
				registers[A3] <= WD3;
			end
//			if (en)
//				x1 <= x1 + 1;
		end
	end
		
	cpu c(
		clk, resetn, pre_en, en,
		cpu_addr,
		read_data,
		cpu_we, cpu_wd,
		mem_src,
		A3, WD3, reg_write
	);
	
//	reg [WORD_SIZE-1:0] x1;
//	reg [WORD_SIZE-1:0] cnt;
//	wire [WORD_SIZE-1:0] x1 = registers[vga_addr];

	
	seven_seg_display h5 (
		x1[23:20],
		HEX5
	);
	seven_seg_display h4 (
		x1[19:16],
		HEX4
	);
	seven_seg_display h3 (
		x1[15:12],
		HEX3
	);
	seven_seg_display h2 (
		x1[11:8],
		HEX2
	);
	seven_seg_display h1 (
		x1[7:4],
		HEX1
	);
	seven_seg_display h0 (
		x1[3:0],
		HEX0
	);
	
	reg old_key;

	
	reg vga_en;
	wire finished_register;
	//always @(posedge clk) begin
		//if(!resetn) begin
	//		x1 <= 0;
//			cnt <= 0;

//			en <= 0;
//			pre_en <= 0;
		//end 
		
		//else begin
			//if (en)
				//x1 <= x1 + 1;
//			if (!old_key && KEY[1]) begin
//				pre_en <= 1;
//			end else begin
//				if (pre_en)
//					en <= 1;
//				else
//					en <= 0;
//				pre_en <= 0;
//			end
//			old_key <= KEY[1];
		
			//if (mem_src == SRC_VGA) begin
//				vga_en <= 1;
//			end else begin
//				vga_en <= 0;
//			end
//				
//			if (vga_en) begin
//				 x1 <= read_data;
//			end
		//end
	//end
	
	mem_ctrl mem (
		clk, resetn,
		cpu_addr, vga_addr,
		cpu_wd,
		cpu_we,
		mem_src,
		//1'b1,
		read_data
	);
	
	//CLOCK_50, KEY, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
	/*
	input CLOCK_50;
	input [3:0] KEY;
	
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK_N;
	output VGA_SYNC_N;
	output VGA_CLK;
	*/
	
	vga_writer v (
		clk, KEY,
		vga_addr, x1,
		VGA_R, VGA_G, VGA_B,
		VGA_HS, VGA_VS,
		VGA_BLANK_N,
		VGA_SYNC_N,
		VGA_CLK,
		finished_register
	);
endmodule

module slow_clock (
	input wire clk, resetn,
	output wire pre_en, en
);
	parameter max = 25_000_000;
	//parameter max = 100_000;
	// parameter max = 5;
	reg [25:0] count;
	always @(posedge clk) begin
		if (!resetn) begin
			count <= 0;
		end else begin
			if (count == max - 1)
				count <= 0;
			else
				count <= count + 1;
		end
	end
	
	assign pre_en = count == max - 2;
	assign en = count == max - 1;
endmodule

// From faculty's design files
module seven_seg_display (hex, display);
   input [3:0] hex;
   output [6:0] display;

   reg [6:0] display;

   /*
    *       0  
    *      ---  
    *     |   |
    *    5|   |1
    *     | 6 |
    *      ---  
    *     |   |
    *    4|   |2
    *     |   |
    *      ---  
    *       3  
    */
   always @ (hex)
       case (hex)
           4'h0: display = 7'b1000000;
           4'h1: display = 7'b1111001;
           4'h2: display = 7'b0100100;
           4'h3: display = 7'b0110000;
           4'h4: display = 7'b0011001;
           4'h5: display = 7'b0010010;
           4'h6: display = 7'b0000010;
           4'h7: display = 7'b1111000;
           4'h8: display = 7'b0000000;
           4'h9: display = 7'b0011000;
           4'hA: display = 7'b0001000;
           4'hB: display = 7'b0000011;
           4'hC: display = 7'b1000110;
           4'hD: display = 7'b0100001;
           4'hE: display = 7'b0000110;
           4'hF: display = 7'b0001110;
       endcase
endmodule