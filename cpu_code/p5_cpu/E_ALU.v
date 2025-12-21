`include "constant.v"

module E_ALU (
	input [31:0] A,
	input [31:0] B,
	input [3:0] ALUOp,
	output [31:0] result
);

assign result = 
(ALUOp == `alu_add) ? A+B:
(ALUOp == `alu_sub) ? A-B:
(ALUOp == `alu_or) ? A|B:
(ALUOp == `alu_shift_b) ? A<<B:
(ALUOp == `alu_shift_16) ? B<<16:
A+B;

endmodule //E_ALU