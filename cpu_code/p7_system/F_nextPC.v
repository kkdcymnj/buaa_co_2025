`include "constant.v"

module F_nextPC (
	input [31:0] F_PC,
	input [31:0] PC_from_rs,
	input handleException,
	input [31:0] EPC,
	input [25:0] instr_index,
	input [15:0] offset,
	input [2:0] nextPCSel,
	input cmpFlag,
	input D_stall,
	//input E_multStall,
	input request,

	output [31:0] nextPC
);

assign nextPC = 
(request) ? 32'h0000_4180 :
(handleException) ? EPC :
(D_stall) ? F_PC:
(nextPCSel == `npc_plus_4) ? F_PC + 4:
(nextPCSel == `npc_like_beq && cmpFlag) ? F_PC + {{14{offset[15]}},{offset},{2'b00}}://是分支语句且满足分支条件
(nextPCSel == `npc_like_jal) ? {{F_PC[31:28]},{instr_index},{2'b00}}:
(nextPCSel == `npc_from_rs) ? PC_from_rs://jr使用
F_PC + 4;

//这样一来可以实现"延迟槽"，PC+4的指令一定会被执行
 
endmodule //D_nextPC