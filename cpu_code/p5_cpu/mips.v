`timescale 1ns / 1ps
`include "constant.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:15:50 11/11/2025 
// Design Name: 
// Module Name:    mips 
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
module mips(
	input clk,
	input reset
);
wire writeEnable,stall,flush;

//level F signal
wire [31:0] F_PC,F_Instr,F_nextPC;

//level D signal
wire [31:0] D_PC,D_PCwith4,D_PCwith8,D_Instr,D_extended,
D_rsVal,D_rtVal,D_rsVal_temp,D_rtVal_temp,D_nextPC;
wire [5:0] D_opCode,D_funct;
wire [4:0] D_rs,D_rt,D_rd,D_shamt;
wire [15:0] D_immediate16;
wire [25:0] D_immediate26;

wire [2:0] D_Tuse_rs, D_Tuse_rt, D_Tnew, D_nextPCSel;
wire [3:0] D_cmpOp, D_ALUOp;
wire [1:0] D_ALU_ASrc, D_ALU_BSrc, D_MemDataType, D_RegWriteAddrSel, D_RegWriteDataSrc;
wire D_extOp, D_MemWrite, D_MemOutSigned, D_RegWrite, D_cmpFlag;
wire D_new;

wire [4:0] D_RegWriteAddr = 
(D_RegWriteAddrSel == `reg_addr_rd) ? D_rd:
(D_RegWriteAddrSel == `reg_addr_rt) ? D_rt:
(D_RegWriteAddrSel == `reg_addr_ra) ? 31:
D_rd;

//level E signal
wire [4:0] E_rs, E_rt, E_RegWriteAddr,E_shamt;
wire [31:0] E_rsVal, E_rtVal, E_rsVal_temp, E_rtVal_temp, E_extended, 
E_PCwith4, E_PCwith8, E_PC, E_ALUOut;
wire [1:0] E_ALU_ASrc, E_ALU_BSrc, E_RegWriteAddrSel, E_RegWriteDataSrc, E_MemDataType;
wire [3:0] E_ALUOp;
wire [2:0] E_Tnew;
wire E_MemWrite, E_MemOutSigned, E_RegWrite;
wire E_new;

wire [31:0] E_A = 
(E_ALU_ASrc == `alu_a_rs) ? E_rsVal:
(E_ALU_ASrc == `alu_a_rt) ? E_rtVal:
E_rsVal;

wire [31:0] E_B = 
(E_ALU_BSrc == `alu_b_rs) ? E_rsVal:
(E_ALU_BSrc == `alu_b_rt) ? E_rtVal:
(E_ALU_BSrc == `alu_b_extended) ? E_extended:
(E_ALU_BSrc == `alu_b_shamt) ? {{27'b0},{E_shamt}}:
E_rtVal;


//level M signal
wire [4:0] M_rs, M_rt, M_RegWriteAddr, M_RegWriteAddrSpecial;
wire [31:0] M_rsVal, M_rsVal_temp, M_rtVal, M_rtVal_temp, M_ALUOut, M_PCwith4, M_PCwith8, M_PC, M_DMOut;
wire [1:0] M_RegWriteAddrSel, M_RegWriteDataSrc, M_MemDataType;
wire [2:0] M_Tnew;
wire M_MemWrite, M_MemOutSigned, M_RegWrite;
wire M_new;

wire [31:0] M_RegWriteData =
(M_RegWriteDataSrc == `reg_data_alu) ? M_ALUOut:
(M_RegWriteDataSrc == `reg_data_pc) ? M_PCwith8:
M_ALUOut;

//level W signal
wire [4:0] W_RegWriteAddr;
wire [31:0] W_ALUOut, W_DMOut, W_PC, W_PCwith4, W_PCwith8;
wire [1:0] W_RegWriteDataSrc;
wire [2:0] W_Tnew;
wire W_RegWrite;
wire W_new;

wire [31:0] W_RegWriteData =
(W_RegWriteDataSrc == `reg_data_alu) ? W_ALUOut:
(W_RegWriteDataSrc == `reg_data_mem) ? W_DMOut:
(W_RegWriteDataSrc == `reg_data_pc) ? W_PCwith8:
W_ALUOut;


/*level F*/
F_IM f_im(
	.currentPC(F_PC),
	.flush(1'b0),
	.Instr(F_Instr)
);

F_PC f_pc(
	.clk(clk),
	.reset(reset),
	.nextPC(F_nextPC),
	
	.currentPC(F_PC)
);

F_nextPC f_nextPC(
	.F_PC(F_PC),
	.PC_from_rs(D_rsVal),
	.instr_index(D_immediate26),
	.offset(D_immediate16),
	.nextPCSel(D_nextPCSel),
	.cmpFlag(D_cmpFlag),
	.stall(stall),
	
	.nextPC(F_nextPC)
);

/*level D*/
D_F2Dreg d_f2dreg(
	.clk(clk),
	.reset(reset),
	.writeEnable(~stall),
	.F_PC(F_PC),
	.F_Instr(F_Instr),
	
	.D_PC(D_PC),
	.D_PCwith4(D_PCwith4),
	.D_PCwith8(D_PCwith8),
	.D_Instr(D_Instr)
);

D_splitter d_splitter(
	.Instr(D_Instr),
	
	.opCode(D_opCode),
	.funct(D_funct),
	.rs(D_rs),
	.rt(D_rt),
	.rd(D_rd),
	.shamt(D_shamt),
	.immediate16(D_immediate16),
	.immediate26(D_immediate26)
);

D_control d_control(
	.opCode(D_opCode),
	.funct(D_funct),

	.Tuse_rs(D_Tuse_rs),
	.Tuse_rt(D_Tuse_rt),
	.Tnew(D_Tnew),
	.nextPCSel(D_nextPCSel),
	.cmpOp(D_cmpOp),
	.extOp(D_extOp),
	.ALU_ASrc(D_ALU_ASrc),
	.ALU_BSrc(D_ALU_BSrc),
	.ALUOp(D_ALUOp),
	.MemWrite(D_MemWrite),
	.MemDataType(D_MemDataType),
	.MemOutSigned(D_MemOutSigned),
	.RegWrite(D_RegWrite),
	.RegWriteAddrSel(D_RegWriteAddrSel),
	.RegWriteDataSrc(D_RegWriteDataSrc),
	.new(D_new)
);



D_GRF d_grf(
	.clk(clk),
	.reset(reset),
	.writeEnable(W_RegWrite),

	.A1(D_rs),
	.A2(D_rt),
	.A3(W_RegWriteAddr),
	.writeData(W_RegWriteData),
	.currentPC(W_PC),

	.RD1(D_rsVal_temp),
	.RD2(D_rtVal_temp)
);

D_extend d_extend(
	.immediate(D_immediate16),
	.extOp(D_extOp),
	
	.result(D_extended)
);

D_cmp d_cmp(
	.Rd1(D_rsVal),
	.Rd2(D_rtVal),
	.cmpOp(D_cmpOp),
	
	.flag(D_cmpFlag)
);

//D级阻塞
D_stall d_stall(
	.Tuse_rs(D_Tuse_rs),
	.Tuse_rt(D_Tuse_rt),
	.E_Tnew(E_Tnew),
	.M_Tnew(M_Tnew),
	.rs(D_rs),
	.rt(D_rt),
	.E_RegWriteAddr(E_RegWriteAddr),
	.M_RegWriteAddr(M_RegWriteAddr),
	.M_RegWriteAddrSpecial(M_RegWriteAddrSpecial),
	.E_RegWrite(E_RegWrite),
	.M_RegWrite(M_RegWrite),

	.E_new(E_new),
	.M_new(M_new),
	.M_rs(M_rs),
	.M_rt(M_rt),
	.E_rs(E_rs),
	.E_rt(E_rt),

	.stall(stall)
);

//D级发送机制
send d_send_rs(
	.RegData(D_rsVal_temp),
	.RegAddr(D_rs),
	
	.M_Tnew(M_Tnew),
	.M_RegWriteAddr((M_new) ? M_RegWriteAddrSpecial : M_RegWriteAddr),
	.M_RegWriteData(M_RegWriteData),
	.M_RegWrite(M_RegWrite),
	
	.W_Tnew(W_Tnew),
	.W_RegWriteAddr(W_RegWriteAddr),
	.M_RegWriteAddrSpecial(M_RegWriteAddrSpecial),
	.W_RegWriteData(W_RegWriteData),
	.W_RegWrite(W_RegWrite),
	
	.new(M_new),
	
	.newRegData(D_rsVal)
);

send d_send_rt(
	.RegData(D_rtVal_temp),
	.RegAddr(D_rt),
	
	.M_Tnew(M_Tnew),
	.M_RegWriteAddr(M_RegWriteAddr),
	.M_RegWriteAddrSpecial(M_RegWriteAddrSpecial),
	.M_RegWriteData(M_RegWriteData),
	.M_RegWrite(M_RegWrite),
	
	.W_Tnew(W_Tnew),
	.W_RegWriteAddr(W_RegWriteAddr),
	.W_RegWriteData(W_RegWriteData),
	.W_RegWrite(W_RegWrite),
	
	.new(M_new),
	
	.newRegData(D_rtVal)
);

/*level E*/
E_D2Ereg e_d2ereg (
	.clk(clk),
	.reset(reset),
	.writeEnable(~stall),

	.D_rs(D_rs),
	.D_rt(D_rt),
	.D_RegWriteAddr(D_RegWriteAddr),
	.D_rsVal(D_rsVal),
	.D_rtVal(D_rtVal),
	.D_extended(D_extended),
	.D_shamt(D_shamt),
	.D_PC(D_PC),
	.D_PCwith4(D_PCwith4),
	.D_PCwith8(D_PCwith8),
	.D_new(D_new),

	.E_rs(E_rs),
	.E_rt(E_rt),
	.E_RegWriteAddr(E_RegWriteAddr),
	.E_rsVal(E_rsVal_temp),
	.E_rtVal(E_rtVal_temp),
	.E_extended(E_extended),
	.E_shamt(E_shamt),
	.E_PC(E_PC),
	.E_PCwith4(E_PCwith4),
	.E_PCwith8(E_PCwith8),
	.E_new(E_new),

	.D_ALU_ASrc(D_ALU_ASrc),
	.D_ALU_BSrc(D_ALU_BSrc),
	.D_ALUOp(D_ALUOp),
	.D_MemWrite(D_MemWrite),
	.D_MemDataType(D_MemDataType),
	.D_MemOutSigned(D_MemOutSigned),
	.D_RegWrite(D_RegWrite),
	.D_RegWriteAddrSel(D_RegWriteAddrSel),
	.D_RegWriteDataSrc(D_RegWriteDataSrc),

	.E_ALU_ASrc(E_ALU_ASrc),
	.E_ALU_BSrc(E_ALU_BSrc),
	.E_ALUOp(E_ALUOp),
	.E_MemWrite(E_MemWrite),
	.E_MemDataType(E_MemDataType),
	.E_MemOutSigned(E_MemOutSigned),
	.E_RegWrite(E_RegWrite),
	.E_RegWriteAddrSel(E_RegWriteAddrSel),
	.E_RegWriteDataSrc(E_RegWriteDataSrc),

	.D_Tnew(D_Tnew),
	.E_Tnew(E_Tnew)
);

//E级发送机制
send e_send_rs(
	.RegData(E_rsVal_temp),
	.RegAddr(E_rs),

	.M_Tnew(M_Tnew),
	.M_RegWriteAddr(M_RegWriteAddr),
	.M_RegWriteAddrSpecial(M_RegWriteAddrSpecial),
	.M_RegWriteData(M_RegWriteData),
	.M_RegWrite(M_RegWrite),

	.W_Tnew(W_Tnew),
	.W_RegWriteAddr(W_RegWriteAddr),
	.W_RegWriteData(W_RegWriteData),
	.W_RegWrite(W_RegWrite),

	.new(M_new),

	.newRegData(E_rsVal)
);

send e_send_rt(
	.RegData(E_rtVal_temp),
	.RegAddr(E_rt),
	
	.M_Tnew(M_Tnew),
	.M_RegWriteAddr(M_RegWriteAddr),
	.M_RegWriteAddrSpecial(M_RegWriteAddrSpecial),
	.M_RegWriteData(M_RegWriteData),
	.M_RegWrite(M_RegWrite),
	
	.W_Tnew(W_Tnew),
	.W_RegWriteAddr(W_RegWriteAddr),
	.W_RegWriteData(W_RegWriteData),
	.W_RegWrite(W_RegWrite),
	
	.new(M_new),
	
	.newRegData(E_rtVal)
);


E_ALU e_ALU(
	.A(E_A),
	.B(E_B),
	.ALUOp(E_ALUOp),
	
	.result(E_ALUOut)
);

/*level M*/
M_E2Mreg m_e2mreg (
	.clk(clk),
	.reset(reset),

	.E_rs(E_rs),
	.E_rt(E_rt),
	.E_rtVal(E_rtVal),
	.E_rsVal(E_rsVal),
	.E_ALUOut(E_ALUOut),
	.E_RegWriteAddr(E_RegWriteAddr),
	.E_PC(E_PC),
	.E_PCwith4(E_PCwith4),
	.E_PCwith8(E_PCwith8),
	.E_new(E_new),

	.M_rs(M_rs),
	.M_rt(M_rt),
	.M_rtVal(M_rtVal_temp),
	.M_rsVal(M_rsVal_temp),
	.M_ALUOut(M_ALUOut),
	.M_RegWriteAddr(M_RegWriteAddr),
	.M_PC(M_PC),
	.M_PCwith4(M_PCwith4),
	.M_PCwith8(M_PCwith8),
	.M_new(M_new),

	.E_MemWrite(E_MemWrite),
	.E_MemDataType(E_MemDataType),
	.E_MemOutSigned(E_MemOutSigned),
	.E_RegWrite(E_RegWrite),
	.E_RegWriteAddrSel(E_RegWriteAddrSel),
	.E_RegWriteDataSrc(E_RegWriteDataSrc),

	.M_MemWrite(M_MemWrite),
	.M_MemDataType(M_MemDataType),
	.M_MemOutSigned(M_MemOutSigned),
	.M_RegWrite(M_RegWrite),
	.M_RegWriteAddrSel(M_RegWriteAddrSel),
	.M_RegWriteDataSrc(M_RegWriteDataSrc),

	.E_Tnew(E_Tnew),
	.M_Tnew(M_Tnew)
);

//M级发送机制
send m_send_rs(
	.RegData(M_rsVal_temp),
	.RegAddr(M_rs),
	
	.M_Tnew(M_Tnew),
	.M_RegWriteAddr(M_RegWriteAddr),
	.M_RegWriteAddrSpecial(M_RegWriteAddrSpecial),
	.M_RegWriteData(M_RegWriteData),
	.M_RegWrite(1'b0),
	
	.W_Tnew(W_Tnew),
	.W_RegWriteAddr(W_RegWriteAddr),
	.W_RegWriteData(W_RegWriteData),
	.W_RegWrite(W_RegWrite),
	
	.new(M_new),
	
	.newRegData(M_rsVal)
);

send m_send_rt(
	.RegData(M_rtVal_temp),
	.RegAddr(M_rt),
	
	.M_Tnew(M_Tnew),
	.M_RegWriteAddr(M_RegWriteAddr),
	.M_RegWriteAddrSpecial(M_RegWriteAddrSpecial),
	.M_RegWriteData(M_RegWriteData),
	.M_RegWrite(1'b0),
	
	.W_Tnew(W_Tnew),
	.W_RegWriteAddr(W_RegWriteAddr),
	.W_RegWriteData(W_RegWriteData),
	.W_RegWrite(W_RegWrite),
	
	.new(M_new),
	
	.newRegData(M_rtVal)
);

M_dataMem m_dm(
	.clk(clk),
	.reset(reset),
	.writeEnable(M_MemWrite),

	//预留
	.new(M_new),
	.rsVal(M_rsVal),
	.rs(M_rs),
	.rt(M_rt),

	.address(M_ALUOut),
	.writeData(M_rtVal),
	.currentPC(M_PC),
	.dataType(M_MemDataType),
	.isSigned(M_MemOutSigned),

	.readData(M_DMOut),
	.RegWriteAddrSpecial(M_RegWriteAddrSpecial)
);

/*level W*/
W_M2Wreg w_m2wreg (
	.clk(clk),
	.reset(reset),

	.M_ALUOut(M_ALUOut),
	.M_DMOut(M_DMOut),
	.M_RegWrite(M_RegWrite),
	.M_RegWriteAddr(M_RegWriteAddr),
	.M_RegWriteDataSrc(M_RegWriteDataSrc),
	.M_Tnew(M_Tnew),
	.M_PC(M_PC),
	.M_PCwith4(M_PCwith4),
	.M_PCwith8(M_PCwith8),
	.M_new(M_new),

	.W_ALUOut(W_ALUOut),
	.W_DMOut(W_DMOut),
	.W_RegWrite(W_RegWrite),
	.W_RegWriteAddr(W_RegWriteAddr),
	.W_RegWriteDataSrc(W_RegWriteDataSrc),
	.W_Tnew(W_Tnew),
	.W_PC(W_PC),
	.W_PCwith4(W_PCwith4),
	.W_PCwith8(W_PCwith8),
	.W_new(W_new)
);



endmodule
