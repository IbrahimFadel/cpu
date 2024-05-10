`include "registers.vh"

module reg_mux(
	input [7:0] register,
	input [15:0] r0, r1, r2, r3,
	output [15:0] out
);
	assign out = register == `R0 ? r0 :
							 register == `R1 ? r1 :
							 register == `R2 ? r2 :
							 register == `R3 ? r3 :
							 {(16){1'bz}};
endmodule