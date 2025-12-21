`include "constant.v"

module E_ALU (
	input [31:0] A,
	input [31:0] B,
	input [3:0] ALUOp,

	//input isLoadOrStore,

	output [31:0] result,
	output overFlow
);

wire [31:0] slt_res = {{31'b0},{$signed(A)<$signed(B)}};

wire [32:0] addRes = {{A[31]},{A}} + {{B[31]},{B}};
wire [32:0] subRes = {{A[31]},{A}} - {{B[31]},{B}};
assign overFlow = 
(ALUOp == `alu_add) ? (addRes[32] != addRes[31]):
(ALUOp == `alu_sub) ? (subRes[32] != subRes[31]):
0;

assign result = 
(ALUOp == `alu_add) ? A+B:
(ALUOp == `alu_sub) ? A-B:
(ALUOp == `alu_or) ? A|B:
(ALUOp == `alu_and) ? A&B:
(ALUOp == `alu_slt) ? slt_res:
(ALUOp == `alu_sltu) ? {{31'b0},{A<B}}:
(ALUOp == `alu_shift_b) ? A<<B:
(ALUOp == `alu_shift_16) ? B<<16:
(ALUOp == `alu_undefined) ? A:
A+B;

endmodule //E_ALU