module mux2 #(parameter WIDTH = 32) (
	input wire [WIDTH-1:0] a, b,
	input wire s,
	output wire [WIDTH-1:0] y
);
	assign y = !s ? a : b;
//	always @(*) begin
//		case(y)
//			1'b0: y = a;
//			1'b1: y = b;
//		endcase
//	end
endmodule

module mux3 #(parameter WIDTH = 32) (
	input wire [WIDTH-1:0] a, b, c,
	input wire [1:0] s,
	output wire [WIDTH-1:0] y
);
	assign y = s == 2'b00 ? a : (s == 2'b01 ? b : c);
//	always @(*) begin
//		case(y)
//			2'b00: y = a;
//			2'b01: y = b;
//			2'b10: y = c;
//			default: y = {WIDTH{1'bx}};
//		endcase
//	end
endmodule

module mux4 #(parameter WIDTH = 32) (
	input wire [WIDTH-1:0] a, b, c, d,
	input wire [1:0] s,
	output wire [WIDTH-1:0] y
);
	assign y = s == 2'b00 ? a : (s == 2'b01 ? b : s == 2'b10 ? c : d);
//	always @(*) begin
//		case(y)
//			2'b00: y = a;
//			2'b01: y = b;
//			2'b10: y = c;
//			default: y = {WIDTH{1'bx}};
//		endcase
//	end
endmodule