`define ADD 0 
`define SUB 1
`define OR 2
`define LogicalLeftS 3
`define LogicalLeft16 4

module ALU (
	input [31:0] A,
	input [31:0] B,
	input [4:0] S,
	input [3:0] op,

	output [31:0] result,
	output zeroFlag
);

assign result = 
(op == `ADD) ? A+B:
(op == `SUB) ? A-B:
(op == `OR) ? A|B:
(op == `LogicalLeftS) ? B<<S:
(op == `LogicalLeft16) ? B<<16:
0;
/*
always @(*) begin
    $display("alu: (A,B,S) = (%h,%h,%h), result: %d",A,B,S,result);
end
*/
assign zeroFlag = (result == 0);

endmodule //alu