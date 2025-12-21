//RegDst
`define rt 0
`define rd 1
`define ra 2
//RegDataSrc
`define alu 0
`define mem 1
`define pc 2
`define special 3
//ALUOp
`define ADD 0
`define SUB 1
`define OR 2
`define LogicalLeftS 3
`define LogicalLeft16 4
`define NewAluOp 5
//dataType
`define word 0
`define half_word 1
`define byte 2

module CTRL (
	input [5:0] op,
	input [5:0] func,

	output [1:0] RegDst,
	output ALUSrc,
	output [1:0] RegDataSrc,
	output RegWrite,
	output MemWrite,
	output MemRead,
	output Branch,
	output ExtOp,
	output [3:0] ALUOp,
	output JumpReturn,
	output Jump,
	output [1:0] dataType,
	output newOrder
);

//op是pecial
wire add = (op==0 && func==6'b100000);
wire sub = (op==0 && func==6'b100010);
wire nop = (op==0 && func==0);
wire sll = (op==0 && func==0);
wire jr = (op==0 && func==6'b001000);
//op不是special
wire ori = (op==6'b001101);
wire lw = (op==6'b100011);
wire sw = (op==6'b101011);
wire beq = (op==6'b000100);
wire lui = (op==6'b001111);
wire jal = (op==6'b000011);
//添加一些奇奇怪怪的指令

assign RegDst = 
(add || sub || nop) ? `rd:
(ori || lw || lui) ? `rt:
(jal) ? `ra:
`rd;

assign ALUSrc = (ori || lw || sw || lui);

assign RegDataSrc =
(add || sub || ori || lui || nop) ? `alu:
(lw) ? `mem:
(jal) ? `pc:
//可以有special通路
`alu;

assign RegWrite = (add || sub || ori || lw || lui || nop || jal);

assign MemWrite = (sw);

assign MemRead = (lw);

assign Branch = (beq);

assign ExtOp = (lw || sw);

assign ALUOp =
(add || lw || sw) ? `ADD:
(sub || beq) ? `SUB:
(ori) ? `OR:
(lui) ? `LogicalLeft16:
(nop) ? `LogicalLeftS :
`ADD;

assign Jump = (jal);

assign JumpReturn = (jr);

assign dataType = 2'b00;

assign newOrder = 0;	//预留给奇怪的指令

endmodule //control