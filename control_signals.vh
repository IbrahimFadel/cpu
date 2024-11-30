parameter ALU_A_SRC_REG = 2'b00;
parameter ALU_A_SRC_PC = 2'b01;

parameter ALU_B_SRC_REG = 2'b00;
parameter ALU_B_SRC_IMM = 2'b01;
parameter ALU_B_SRC_1 = 2'b10;

parameter ALU_OP_ADD = 4'b0000;
parameter ALU_OP_SUB = 4'b0001;
parameter ALU_OP_SLL = 4'b0010;
parameter ALU_OP_SRL = 4'b0011;
parameter ALU_OP_XOR = 4'b0100;
parameter ALU_OP_OR = 4'b0101;
parameter ALU_OP_AND = 4'b0101;
parameter ALU_OP_MUL = 4'b0110;
parameter ALU_OP_DIV = 4'b0111;
parameter ALU_OP_LT = 4'b1000;

parameter RESULT_SRC_ALU = 2'b00;
parameter RESULT_SRC_RD = 2'b01;
parameter RESULT_SRC_PCP4 = 2'b10;
parameter RESULT_SRC_LOADED = 2'b11;

parameter RTYPE = 2'b00;
parameter ITYPE = 2'b01;
parameter STYPE = 2'b10;
parameter BTYPE = 2'b11;

parameter ADDR_SRC_PC = 1'b0;
parameter ADDR_SRC_AR = 1'b1;

parameter AR_SRC_ALU = 1'b0;
parameter AR_SRC_REG_ADDR = 1'b1;

parameter SRC_CPU = 1'b0;
parameter SRC_VGA = 1'b1;