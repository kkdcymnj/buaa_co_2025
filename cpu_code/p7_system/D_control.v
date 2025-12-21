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
	input [4:0] rs,
	input [4:0] rd,

	output [2:0] Tuse_rs,
	output [2:0] Tuse_rt,
	output [2:0] Tnew,
	output [2:0] nextPCSel,//0:+4,1:like_beq,2:like_jal,3:rs
	output [3:0] cmpOp,
	output [3:0] extOp,
	output [1:0] ALU_ASrc,//0:rs,1:rt
	output [1:0] ALU_BSrc,//0:rt,1:extended,2:shamt,3:rs
	output [3:0] ALUOp,//0:add,1:sub,2:or,3:shift_b,4:shift_16
	output MemWrite,
	output [1:0] MemDataType,//0:word,1:half,2:byte
	output MemOutSigned,
	output RegWrite,
	output [1:0] RegWriteAddrSel,//0:rd,1:rt,2:ra
	output [2:0] RegWriteDataSrc,//0:alu,1:mem,2:pc,3:hilo

	output [3:0] MultOp,
	output [31:0] calcTime,
	output doMULT,

	//预留
	output new,

	//未知指令异常
	output RI,

	//是否是延迟槽指令
	output BD,

	//是否是异常处理指令eret
	output handleException,

	//写CP0寄存器
	output cp0WriteEnable,
	output [4:0] cp0Addr,

	//是否是系统中断
	output Syscall,

	output isLoadOrStore
);

//R算数指令
wire add = (opCode==0 && funct==6'b100000);
wire sub = (opCode==0 && funct==6'b100010);
wire AND = (opCode==0 && funct==6'b100100);
wire OR  = (opCode==0 && funct==6'b100101);
wire slt = (opCode==0 && funct==6'b101010);
wire sltu = (opCode==0 && funct==6'b101011);
wire addu = (opCode==0 && funct==6'b100001);

//I算数指令
wire addi = (opCode==6'b001000);
wire andi = (opCode==6'b001100);
wire ori = (opCode==6'b001101);
wire lui = (opCode==6'b001111);
wire addiu = (opCode == 6'b001001);

//乘除指令
wire mult = (opCode==0 && funct==6'b011000);
wire multu = (opCode==0 && funct==6'b011001);
wire div = (opCode==0 && funct==6'b011010);
wire divu = (opCode==0 && funct==6'b011011);

//hilo指令
wire mfhi = (opCode==0 && funct==6'b010000);
wire mflo = (opCode==0 && funct==6'b010010);
wire mthi = (opCode==0 && funct==6'b010001);
wire mtlo = (opCode==0 && funct==6'b010011);

//load指令
wire lw = (opCode==6'b100011);
wire lh = (opCode==6'b100001);
wire lb = (opCode==6'b100000);

//store指令
wire sw = (opCode==6'b101011);
wire sh = (opCode==6'b101001);
wire sb = (opCode==6'b101000);

//分支指令
wire beq = (opCode==6'b000100);
wire bne = (opCode==6'b000101);

//跳转链接指令
wire j = (opCode==6'b000010);
wire jal = (opCode==6'b000011);

//跳回指令
wire jr = (opCode==0 && funct==6'b001000);

//其他
wire nop = (opCode==0 && funct==0);
wire sll = (opCode==0 && funct==0);

//异常处理
wire eret = (opCode == 6'b010000 && funct == 6'b011000 && rs==5'b10000);
assign handleException = eret;

//写CP0寄存器
wire mtc0 = (opCode == 6'b010000 && funct == 6'b000000 && rs==5'b00100);
assign cp0WriteEnable = mtc0;
assign cp0Addr = rd;

//系统中断
wire syscall = (opCode == 6'b000000 && funct == 6'b001100);
assign Syscall = syscall;

wire mfc0 = (opCode == 6'b010000 && funct == 6'b000000 && rs==5'b00000);

//预留新指令

//下一个指令是否延迟槽
assign BD = 
(j | jal | jr | beq | bne);

//未知指令异常
assign RI = 
!(
	add | sub | AND | OR | slt | sltu | addu |
	addi | andi | ori | lui | addiu |
	mult | multu | div | divu |
	mfhi | mflo | mthi | mtlo |
	lw | lh | lb |
	sw | sh | sb |
	beq | bne |
	j | jal |
	jr |
	nop | sll |
	eret | mfc0 | mtc0 | syscall
);

//信号生成
assign Tuse_rs = 
(
	beq || bne || 
	jr
) ? 0:
(
	add || sub || AND || OR || slt || sltu || addu ||
	addi || andi || ori || addiu ||
	mult || multu || div || divu ||
	mfhi || mflo || mthi || mtlo ||
	lw || lh || lb ||
	sw || sh || sb 
) ? 1:
7;//不使用rs

assign Tuse_rt = 
(
	beq || bne
) ? 0:
(
	add || sub || AND || OR || slt || sltu || addu ||
	lui ||
	mult || multu || div || divu ||
	nop || sll
) ? 1:
(
	lw || lh || lb ||
	sw || sh || sb ||
	mtc0
) ? 2:
7;//不使用rt

assign Tnew = 
(
	add || sub || AND || OR || slt || sltu || addu ||
	addi || andi || ori || lui || addiu ||
	mfhi || mflo || 
	jal 
) ? 2:
(
	lw || lh || lb ||
	mfc0
) ? 3:
0;

assign nextPCSel = 
(beq || bne) ? `npc_like_beq:
(jal || j) ? `npc_like_jal:
(jr) ? `npc_from_rs:
(eret) ? `npc_from_epc:
`npc_plus_4;

assign cmpOp = 
(beq) ? `cmp_beq:
(bne) ? `cmp_bne:
`cmp_beq;

assign extOp = 
(
	lw || lh || lb ||
	sw || sh || sb ||
	addi || addiu
) ? `ext_signed://16位立即数有符号扩展
`ext_unsigned;

assign ALU_ASrc =
(
	nop || sll || mtc0
) ? `alu_a_rt:
`alu_a_rs;

assign ALU_BSrc = 
(
	addi || andi || ori || lui || addiu ||
	lw || lh || lb ||
	sw || sh || sb
) ? `alu_b_extended:
(
	nop || sll
) ? `alu_b_shamt:
`alu_b_rt;

assign ALUOp = 
(
	add || addu ||
	addi || addiu ||
	lw || lh || lb ||
	sw || sh || sb 
) ? `alu_add:
(
	sub 
) ? `alu_sub:
(
	OR ||
	ori 
) ? `alu_or:
(
	AND ||
   andi 
) ? `alu_and:
(
	slt
) ? `alu_slt:
(
	sltu
) ? `alu_sltu:
(
	lui
) ? `alu_shift_16:
(
	nop
) ? `alu_shift_b:
//预留新指令
`alu_undefined;

assign MultOp = 
(mult) ? `mult_mult:
(multu) ? `mult_multu:
(div) ? `mult_div:
(divu) ? `mult_divu:
(mfhi) ? `mult_mfhi:
(mflo) ? `mult_mflo:
(mthi) ? `mult_mthi:
(mtlo) ? `mult_mtlo:
`mult_undefined;

assign calcTime = 
(mult || multu) ? 5:
(div || divu) ? 10:
0;
 
assign MemWrite =
(sw || sh || sb);

assign MemDataType =
(lh || sh) ? `dm_half:
(lb || sb) ? `dm_BYTE:
`dm_word;

assign MemOutSigned = (lh || lb);

assign RegWrite =
(
	add || sub || AND || OR || slt || sltu || addu ||
	addi || andi || ori || lui || addiu || 
	mfhi || mflo ||
	lb || lh || lw ||
	nop || sll ||
	jal ||
	mfc0
);

assign RegWriteAddrSel =
(
	addi || andi || ori || lui || addiu ||
	lb || lh || lw ||
	mfc0
) ? `reg_addr_rt:
(jal) ? `reg_addr_ra:
//可以有special通路
`reg_addr_rd;

assign RegWriteDataSrc =
(
	add || sub || AND || OR || slt || sltu || addu ||
	addi || andi || ori || lui || addiu
) ? `reg_data_alu:
(mfhi) ? `reg_data_hi:
(mflo) ? `reg_data_lo:
(lw || lh || lb) ? `reg_data_mem:
(jal) ? `reg_data_pc:
(mfc0) ? `reg_data_cp0:
//可以有special通路
`reg_data_alu;

assign new = 0;

assign doMULT = (MultOp!=`mult_undefined);

assign isLoadOrStore =
(
	lw || lh || lb ||
	sw || sh || sb
);

endmodule
