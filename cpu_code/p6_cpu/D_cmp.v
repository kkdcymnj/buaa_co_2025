`include "constant.v"

module D_cmp (
	input  [31:0 ]  Rd1,
	input  [31:0 ]  Rd2,
	input  [ 3:0 ]  cmpOp,

	output flag
);

//wire beq = (cmpOp == `cmp_beq);

assign flag = 
(cmpOp == `cmp_beq) ? (Rd1 == Rd2):
(cmpOp == `cmp_bne) ? (Rd1 != Rd2):
(Rd1 == Rd2);

endmodule //D_cmp