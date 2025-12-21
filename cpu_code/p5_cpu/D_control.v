`timescale 1ns / 1ps
`include "constant.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:11:55 11/11/2025 
// Design Name: 
// Module Name:    D_decode 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module D_control(
	input [5:0] opCode,
	input [5:0] funct,

	output [2:0] Tuse_rs,
	output [2:0] Tuse_rt,
	output [2:0] Tnew,
	output [2:0] nextPCSel,//0:+4,1:like_beq,2:like_jal,3:rs
	output [3:0] cmpOp,
	output extOp,
	output [1:0] ALU_ASrc,//0:rs,1:rt
	output [1:0] ALU_BSrc,//0:rt,1:extended,2:shamt,3:rs
	output [3:0] ALUOp,//0:add,1:sub,2:or,3:shift_b,4:shift_16
	output MemWrite,
	output [1:0] MemDataType,//0:word,1:half,2:byte
	output MemOutSigned,
	output RegWrite,
	output [1:0] RegWriteAddrSel,//0:rd,1:rt,2:ra
	output [1:0] RegWriteDataSrc,//0:alu,1:mem,2:pc

	//预留
	output new
);

//op是pecial
wire add = (opCode==0 && funct==6'b100000);
wire sub = (opCode==0 && funct==6'b100010);
wire nop = (opCode==0 && funct==0);
wire sll = (opCode==0 && funct==0);
wire jr = (opCode==0 && funct==6'b001000);
//op不是special
wire ori = (opCode==6'b001101);
wire lw = (opCode==6'b100011);
wire sw = (opCode==6'b101011);
wire beq = (opCode==6'b000100);
wire lui = (opCode==6'b001111);
wire jal = (opCode==6'b000011);
//预留新指令

//信号生成
assign Tuse_rs = 
(beq || jr)?0:
(add || sub || lw || sw || ori )?1:
7;//不使用rs

assign Tuse_rt = 
(beq)?0:
(add || sub || nop)?1:
(lw )?2:
7;//不使用rt

assign Tnew = 
(add || sub || ori || lui || nop)?2:
(lw )?3:
0;

assign nextPCSel = 
(add || sub || ori || lui || lw || sw || nop )?`npc_plus_4:
(beq)?`npc_like_beq:
(jal)?`npc_like_jal:
(jr)?`npc_from_rs:
`npc_plus_4;

assign cmpOp = 
(beq) ? `cmp_beq:
`cmp_beq;

assign extOp = 
(lw || sw ) ? 1://16位立即数有符号扩展
0;

assign ALU_ASrc =
(nop)?`alu_a_rt:
`alu_a_rs;

assign ALU_BSrc = 
(lui || lw || sw || ori )?`alu_b_extended:
(nop)?`alu_b_shamt:
`alu_b_rt;

assign ALUOp = 
(add || lw || sw  ) ? `alu_add:
(sub) ? `alu_sub:
(lui) ? `alu_shift_16:
(nop) ? `alu_shift_b:
(ori) ? `alu_or:
//预留新指令
`alu_add;

assign MemWrite =
(sw);

assign MemDataType =
(sw || lw) ? `dm_word:
`dm_word;

assign MemOutSigned =
(sw || lw ) ? 0:
0;

assign RegWrite =
(add || sub || lw || ori || lui || nop || jal );

assign RegWriteAddrSel =
(add || sub || nop) ? `reg_addr_rd:
(ori || lw || lui) ? `reg_addr_rt:
(jal) ? `reg_addr_ra:
`reg_addr_rd;

assign RegWriteDataSrc =
(add || sub || ori || lui || nop) ? `reg_data_alu:
(lw ) ? `reg_data_mem:
(jal) ? `reg_data_pc:
//可以有special通路
`reg_data_alu;

assign new = (0);

endmodule
