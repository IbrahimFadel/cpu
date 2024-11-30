`timescale 1ns / 1ps

module tb();
	parameter CLOCK_PERIOD = 10;
	
	reg clk, resetn, en;
	reg [9:0] SW;
	wire [9:0] LEDR;
	wire [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	top u1 (clk, SW, {en, resetn}, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR);

	always @ (*)
		begin : Clock_Generator
			#((CLOCK_PERIOD) / 2) clk <= ~clk;
	end
	
	always @ (*)
		begin : En_Generator
			#((CLOCK_PERIOD) / 0.5) en <= ~en;
	end

	initial begin
		clk <= 0;
		resetn <= 0;
		en <= 0;
		SW <= 2;
		#10;
		resetn <= 1;
		#20;
	end
endmodule


//`timescale 1ns / 1ps
//
//module testbench ( );
//
//	parameter CLOCK_PERIOD = 10;
//
//    reg [2:0] SW;
//    reg [1:0] KEY;
//    reg CLOCK_50;
//    wire [9:0] LEDR;
//
//	initial begin
//        CLOCK_50 <= 1'b0;
//	end // initial
//	always @ (*)
//	begin : Clock_Generator
//		#((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
//	end
//	
//	initial begin
//        KEY[0] <= 1'b0;
//        #10 KEY[0] <= 1'b1;
//	end // initial
//
//    // In the setup below we assume that the half_sec_enable signal coming
//    // from the half-second clock is asserted every 3 cycles of CLOCK_50. Of
//    // course, in the real circuit the half-second clock is asserted every
//    // 25M cycles. The setup below produces the Morse code for A (.-) followed
//    // by the Morse code for B (-...).
//	initial begin
//        SW <= 3'b000; KEY[1] = 1; // not pressed;
//        #20 KEY[1] <= 0; // pressed
//        #10 KEY[1] <= 1; // not pressed
//        #190 SW <= 3'b001;
//        #10 KEY[1] <= 0; // pressed
//        #10 KEY[1] <= 1; // not pressed
//	end // initial
//	part3 U1 (CLOCK_50, SW, KEY, LEDR);
//
//endmodule
