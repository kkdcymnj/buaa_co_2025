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
	input reset,
	input interrupt,
	output [31:0] macroscopic_pc,

	input [31:0] i_inst_rdata,
	input [31:0] m_data_rdata,
	output [31:0] i_inst_addr,

	output [31:0] m_data_addr,
	output [31:0] m_data_wdata,
	output [3 :0] m_data_byteen,
	output [31:0] m_inst_addr,

	output [31:0] m_int_addr,     // 中断发生器待写入地址
	output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

	output w_grf_we,
	output [4:0] w_grf_addr,
	output [31:0] w_grf_wdata,
	output [31:0] w_inst_addr
);//存储器外置
	 
wire writeEnable,D_stall,E_multStall;
wire flush=0;

assign macroscopic_pc = M_PC;//宏观PC

//level F signal
wire [31:0] F_PC,F_Instr,F_nextPC;
wire F_PCOutOfRange, F_PCfalse;
wire [4:0] F_exceptionCode;

//level D signal
wire [31:0] D_PC,D_PCwith4,D_PCwith8,D_Instr,D_extended,
D_rsVal,D_rtVal,D_rsVal_temp,D_rtVal_temp,D_nextPC,D_calcTime;
wire [5:0] D_opCode,D_funct;
wire [4:0] D_rs,D_rt,D_rd,D_shamt;
wire [15:0] D_immediate16;
wire [25:0] D_immediate26;

wire [2:0] D_Tuse_rs, D_Tuse_rt, D_Tnew, D_nextPCSel, D_RegWriteDataSrc;
wire [3:0] D_cmpOp, D_ALUOp, D_extOp, D_MultOp;
wire [1:0] D_ALU_ASrc, D_ALU_BSrc, D_MemDataType, D_RegWriteAddrSel;
wire D_MemWrite, D_MemOutSigned, D_RegWrite, D_cmpFlag, D_isLoadOrStore;
wire D_new;
wire D_doMULT;

wire D_RI, D_BD, D_Syscall, D_handleException, D_cp0WriteEnable, BD;
wire [4:0] D_cp0Addr;
wire D_PCOutOfRange, D_PCfalse;

wire [4:0] D_exceptionCode, D_exceptionCodeTemp;

wire [4:0] D_RegWriteAddr = 
(D_RegWriteAddrSel == `reg_addr_rd) ? D_rd:
(D_RegWriteAddrSel == `reg_addr_rt) ? D_rt:
(D_RegWriteAddrSel == `reg_addr_ra) ? 31:
D_rd;

//level E signal
wire [4:0] E_rs, E_rt, E_RegWriteAddr,E_shamt;
wire [31:0] E_rsVal, E_rtVal, E_rsVal_temp, E_rtVal_temp, E_extended, 
E_PCwith4, E_PCwith8, E_PC, E_ALUOut, E_HIOut, E_LOOut, E_calcTime;
wire [1:0] E_ALU_ASrc, E_ALU_BSrc, E_RegWriteAddrSel, E_MemDataType;
wire [3:0] E_ALUOp, E_MultOp;
wire [2:0] E_Tnew, E_RegWriteDataSrc;
wire E_MemWrite, E_MemOutSigned, E_RegWrite, E_start, E_busy;
wire E_new;

wire E_Ov, E_RI, E_BD, E_Syscall, E_handleException, E_cp0WriteEnable, 
E_isLoadOrStore;
wire [4:0] E_cp0Addr;
wire E_PCOutOfRange, E_PCfalse;

wire [4:0] E_exceptionCode, E_exceptionCodeTemp;

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
wire [31:0] M_rsVal, M_rsVal_temp, M_rtVal, M_rtVal_temp, M_ALUOut, 
M_PCwith4, M_PCwith8, M_PC, M_DMOut, M_HIOut, M_LOOut, M_CP0Out,
M_EPCOut;
wire [31:0] M_timerOutData;
wire [1:0] M_RegWriteAddrSel, M_MemDataType;
wire [2:0] M_Tnew, M_RegWriteDataSrc;
wire [3:0] M_byteEnable;
wire M_MemWrite, M_MemOutSigned, M_RegWrite;
wire M_new;

wire M_Ov, M_RI, M_BD, M_Syscall, M_handleException, M_cp0WriteEnable;
wire [4:0] M_cp0Addr;
wire M_PCOutOfRange, M_PCfalse, M_externalInterruptResponse;

wire [4:0] M_exceptionCode, M_exceptionCodeTemp;

wire [31:0] M_RegWriteData =
(M_RegWriteDataSrc == `reg_data_alu) ? M_ALUOut:
(M_RegWriteDataSrc == `reg_data_pc) ? M_PCwith8:
(M_RegWriteDataSrc == `reg_data_hi) ? M_HIOut:
(M_RegWriteDataSrc == `reg_data_lo) ? M_LOOut:
M_ALUOut;

//level W signal
wire [4:0] W_RegWriteAddr;
wire [31:0] W_ALUOut, W_DMOut, W_PC, W_PCwith4, W_PCwith8, W_HIOut, W_LOOut,
W_CP0Out, W_EPCOut;
wire [2:0] W_Tnew, W_RegWriteDataSrc;
wire W_RegWrite;
wire W_new;

wire [31:0] W_RegWriteData =
(W_RegWriteDataSrc == `reg_data_alu) ? W_ALUOut:
(W_RegWriteDataSrc == `reg_data_mem) ? W_DMOut:
(W_RegWriteDataSrc == `reg_data_pc) ? W_PCwith8:
(W_RegWriteDataSrc == `reg_data_hi) ? W_HIOut:
(W_RegWriteDataSrc == `reg_data_lo) ? W_LOOut:
(W_RegWriteDataSrc == `reg_data_cp0) ? W_CP0Out:
W_ALUOut;

/*level F*/

assign i_inst_addr = F_PC;

assign F_Instr = 
(flush || F_exceptionCode == `cp0_AdEL || D_handleException) ? 32'b0 : i_inst_rdata;

assign F_PCOutOfRange =
(i_inst_addr < 32'h0000_3000 || i_inst_addr > 32'h0000_6fff);

assign F_PCfalse = 
(i_inst_addr[1:0] != 2'b00);

assign F_exceptionCode = 
((F_PCOutOfRange || F_PCfalse) && !D_handleException) ?  `cp0_AdEL : 1;
//若异常处理代码地址超过6fff，也不判定PC越界

F_PC f_pc(
	.clk(clk),
	.reset(reset),
	.nextPC(F_nextPC),

	.currentPC(F_PC)
);

F_nextPC f_nextPC(
	.F_PC(F_PC),
	.PC_from_rs(D_rsVal),
	.handleException(D_handleException),
	.EPC(M_EPCOut),
	.instr_index(D_immediate26),
	.offset(D_immediate16),
	.nextPCSel(D_nextPCSel),
	.cmpFlag(D_cmpFlag),
	.D_stall(D_stall),
	//.E_multStall(E_multStall),
	.request(M_Request),
	
	.nextPC(F_nextPC)
);

/*level D*/
D_F2Dreg d_f2dreg(
	.clk(clk),
	.reset(reset),
	.F_PC(F_PC),
	.F_Instr(F_Instr),
	.D_stall(D_stall),
	//.E_multStall(E_multStall),
	.request(M_Request),
	
	.D_PC(D_PC),
	.D_PCwith4(D_PCwith4),
	.D_PCwith8(D_PCwith8),
	.D_Instr(D_Instr),

	.F_PCOutOfRange(F_PCOutOfRange),
	.F_PCfalse(F_PCfalse),
	.D_PCOutOfRange(D_PCOutOfRange),
	.D_PCfalse(D_PCfalse),
	
	.F_exceptionCode(F_exceptionCode),
	.D_exceptionCodeTemp(D_exceptionCodeTemp),
	
	.F_BD(BD),
	.D_BD(D_BD)
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
	.rs(D_rs),
	.rd(D_rd),

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

	.calcTime(D_calcTime),
	.MultOp(D_MultOp),
	.doMULT(D_doMULT),

	.new(D_new),

	.RI(D_RI),
	.BD(BD),
	.handleException(D_handleException),
	.cp0WriteEnable(D_cp0WriteEnable),
	.cp0Addr(D_cp0Addr),
	.Syscall(D_Syscall),

	.isLoadOrStore(D_isLoadOrStore)
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
	
	.D_doMult(D_doMULT),
	.E_start(E_start),
	.E_busy(E_busy),
	
	.E_new(E_new),
	.M_new(M_new),
	.M_rs(M_rs),
	.M_rt(M_rt),
	.E_rs(E_rs),
	.E_rt(E_rt),
	
	.D_handleException(D_handleException),
	.M_cp0WriteEnable(M_cp0WriteEnable),
	.M_cp0Addr(M_cp0Addr),
	.E_cp0WriteEnable(E_cp0WriteEnable),
	.E_cp0Addr(E_cp0Addr),
	
	.stall(D_stall)
);

//D级发送机制
send d_send_rs(
	.RegData(D_rsVal_temp),
	.RegAddr(D_rs),
	
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

assign D_exceptionCode = 
(D_exceptionCodeTemp != 1) ? D_exceptionCodeTemp : 
(D_Syscall) ? `cp0_Syscall :
(D_RI) ? `cp0_RI :
1;

/*level E*/
E_D2Ereg e_d2ereg (
	.clk(clk),
	.reset(reset),
	.D_stall(D_stall),
	//.E_multStall(E_multStall),
	.request(M_Request),

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
	.D_calcTime(D_calcTime),
	.D_MultOp(D_MultOp),

	.E_ALU_ASrc(E_ALU_ASrc),
	.E_ALU_BSrc(E_ALU_BSrc),
	.E_ALUOp(E_ALUOp),
	.E_MemWrite(E_MemWrite),
	.E_MemDataType(E_MemDataType),
	.E_MemOutSigned(E_MemOutSigned),
	.E_RegWrite(E_RegWrite),
	.E_RegWriteAddrSel(E_RegWriteAddrSel),
	.E_RegWriteDataSrc(E_RegWriteDataSrc),
	.E_calcTime(E_calcTime),
	.E_MultOp(E_MultOp),

	.D_Tnew(D_Tnew),
	.E_Tnew(E_Tnew),

	.D_BD(D_BD),
	.D_RI(D_RI),
	.E_BD(E_BD),
	.E_RI(E_RI),
	.D_handleException(D_handleException),
	.D_cp0WriteEnable(D_cp0WriteEnable),
	.D_Syscall(D_Syscall),
	.D_cp0Addr(D_cp0Addr),
	.E_handleException(E_handleException),
	.E_cp0WriteEnable(E_cp0WriteEnable),
	.E_Syscall(E_Syscall),
	.E_cp0Addr(E_cp0Addr),

	.D_PCOutOfRange(D_PCOutOfRange),
	.D_PCfalse(D_PCfalse),
	.E_PCOutOfRange(E_PCOutOfRange),
	.E_PCfalse(E_PCfalse),

	.D_exceptionCode(D_exceptionCode),
	.E_exceptionCodeTemp(E_exceptionCodeTemp),
	
	.D_isLoadOrStore(D_isLoadOrStore),
	.E_isLoadOrStore(E_isLoadOrStore)
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

//E级ALU
E_ALU e_ALU(
	.A(E_A),
	.B(E_B),
	.ALUOp(E_ALUOp),

	//.isLoadOrStore(E_isLoadOrStore),
	
	.result(E_ALUOut),
	.overFlow(E_Ov)
);

//E级乘除模块
E_MULT e_MULT(
	.clk(clk),
	.reset(reset),
	.request(M_Request),
	
	.A(E_A),
	.B(E_B),
	.MultOp(E_MultOp),
	.calcTime(E_calcTime),
	
	.HI(E_HIOut),
	.LO(E_LOOut),
	.start(E_start),
	.busy(E_busy)
);

assign E_multStall = D_doMULT && (E_start || E_busy);

assign E_exceptionCode = 
(E_exceptionCodeTemp != 1) ? E_exceptionCodeTemp : 
(E_Ov && !E_isLoadOrStore) ? `cp0_Ov :
1;

/*level M*/

//M级异常机制
wire M_lw = 
(M_RegWriteDataSrc == `reg_data_mem && M_MemDataType == `dm_word);

wire M_lwAddrException = 
M_lw && (M_ALUOut[1:0] != 2'b00);  

wire M_lh = 
(M_RegWriteDataSrc == `reg_data_mem && M_MemDataType == `dm_half);

wire M_lhAddrException = 
M_lh && (M_ALUOut[0] != 1'b0);    

wire M_lb = 
(M_RegWriteDataSrc == `reg_data_mem && M_MemDataType == `dm_BYTE);

wire M_sw = 
(M_MemWrite && M_MemDataType == `dm_word);

wire M_swAddrException = 
M_sw && (M_ALUOut[1:0] != 2'b00);  

wire M_sh = 
(M_MemWrite && M_MemDataType == `dm_half);

wire M_shAddrException = 
M_sh && (M_ALUOut[0] != 1'b0);     

wire M_sb = 
(M_MemWrite && M_MemDataType == `dm_BYTE);

wire M_loadAddrCalcOv = 
(M_lw || M_lh || M_lb) && M_Ov;

wire M_saveAddrCalcOv = 
(M_sw || M_sh || M_sb) && M_Ov;

wire M_arithOv = 
((M_lw | M_lh | M_lb | M_sw | M_sh | M_sb)==1'b0) && M_Ov;

wire M_loadFromTimer = 
(M_lh || M_lb) && 
((M_ALUOut >= 32'h0000_7F00 && M_ALUOut <= 32'h0000_7F0B) ||
(M_ALUOut >= 32'h0000_7F10 && M_ALUOut <= 32'h0000_7F1B));

wire M_saveToTimer = 
(M_sh || M_sb) && 
((M_ALUOut >= 32'h0000_7F00 && M_ALUOut <= 32'h0000_7F0B) ||
(M_ALUOut >= 32'h0000_7F10 && M_ALUOut <= 32'h0000_7F1B));

wire M_saveToCount =
(M_sw || M_sh || M_sb) && 
((M_ALUOut >= 32'h0000_7F08 && M_ALUOut <= 32'h0000_7F0B) ||
(M_ALUOut >= 32'h0000_7F18 && M_ALUOut <= 32'h0000_7F1B));

wire M_loadOutOfRange = 
(M_lw || M_lh || M_lb) && 
!( (M_ALUOut >= 32'h0000_0000 && M_ALUOut <= 32'h0000_2FFF) ||  // 数据存储器范围
   (M_ALUOut >= 32'h0000_7F00 && M_ALUOut <= 32'h0000_7F0B) ||  // 计时器0范围
   (M_ALUOut >= 32'h0000_7F10 && M_ALUOut <= 32'h0000_7F1B) ||  // 计时器1范围
   (M_ALUOut >= 32'h0000_7F20 && M_ALUOut <= 32'h0000_7F23) );  // 中断发生器范围
	
wire M_saveOutOfRange = 
(M_sw || M_sh || M_sb) && 
!( (M_ALUOut >= 32'h0000_0000 && M_ALUOut <= 32'h0000_2FFF) ||  // 数据存储器范围
   (M_ALUOut >= 32'h0000_7F00 && M_ALUOut <= 32'h0000_7F0B) ||  // 计时器0范围
   (M_ALUOut >= 32'h0000_7F10 && M_ALUOut <= 32'h0000_7F1B) ||  // 计时器1范围
   (M_ALUOut >= 32'h0000_7F20 && M_ALUOut <= 32'h0000_7F23) );  // 中断发生器范围

wire [5:0] M_HWInt = 
{{3'b000},{interrupt},{P_timer1IRQ},{P_timer0IRQ}};
		
wire M_AdEL = 
M_loadAddrCalcOv ||           // 加载地址计算溢出
M_lwAddrException ||          // lw地址不对齐
M_lhAddrException ||          // lh地址不对齐
M_loadOutOfRange ||           // 加载地址越界
M_loadFromTimer;              // 从计时器加载半字/字节

wire M_AdES =
M_saveAddrCalcOv ||           // 存储地址计算溢出
M_swAddrException ||          // sw地址不对齐
M_shAddrException ||          // sh地址不对齐
M_saveOutOfRange ||           // 存储地址越界
M_saveToTimer ||              // 向计时器存储半字/字节
M_saveToCount;				  // 向Count寄存器存储

assign M_exceptionCode = 
(M_exceptionCodeTemp != 1) ? M_exceptionCodeTemp : 
(M_arithOv) ? `cp0_Ov:
(M_AdEL) ? `cp0_AdEL :
(M_AdES) ? `cp0_AdES:
1;

/*wire [31:0] M_VPC = 
(M_BD) ? (M_PC -4) : M_PC;*/

M_CP0 m_cp0(
	.clk(clk),
	.reset(reset),
	.writeEnable(M_cp0WriteEnable),
	.CP0Addr(M_cp0Addr),
	.CP0In(M_rtVal),
	.CP0Out(M_CP0Out),

	.M_PC(M_PC),
	.BDIn(M_BD),
	.ExcCodeIn(M_exceptionCode),
	.HWInt(M_HWInt),
	.EXLClear(M_handleException),	//异常信号清空
	.EPCOut(M_EPCOut),
	.Request(M_Request),
	.externalInterruptResponse(M_externalInterruptResponse)
);

M_E2Mreg m_e2mreg (
	.clk(clk),
	.reset(reset),
	.request(M_Request),

	.E_rs(E_rs),
	.E_rt(E_rt),
	.E_rtVal(E_rtVal),
	.E_rsVal(E_rsVal),
	.E_ALUOut(E_ALUOut),
	.E_HIOut(E_HIOut),
	.E_LOOut(E_LOOut),
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
	.M_HIOut(M_HIOut),
	.M_LOOut(M_LOOut),
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
	.M_Tnew(M_Tnew),

	.E_BD(E_BD),
	.E_RI(E_RI),
	.M_BD(M_BD),
	.M_RI(M_RI),

	.E_handleException(E_handleException),
	.E_Syscall(E_Syscall),
	.E_cp0WriteEnable(E_cp0WriteEnable),
	.E_cp0Addr(E_cp0Addr),
	.M_handleException(M_handleException),
	.M_Syscall(M_Syscall),
	.M_cp0WriteEnable(M_cp0WriteEnable),
	.M_cp0Addr(M_cp0Addr),

	.E_Ov(E_Ov),
	.M_Ov(M_Ov),

	.E_PCOutOfRange(E_PCOutOfRange),
	.E_PCfalse(E_PCfalse),
	.M_PCOutOfRange(M_PCOutOfRange),
	.M_PCfalse(M_PCfalse),

	.E_exceptionCode(E_exceptionCode),
	.M_exceptionCodeTemp(M_exceptionCodeTemp)
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

M_DMByteEnable m_DM_byte_enable(
	.writeEnable(M_MemWrite),
	.request(M_Request),
	.dataType(M_MemDataType),
	.address(m_data_addr),
	.M_AdEL(M_AdEL),
	.M_AdES(M_AdES),
	
	.byteEnable(m_data_byteen)
);

//读出数据时
M_DMDataExt m_DM_data_ext(
	.addr(m_data_addr),
	.DM_in(m_data_rdata),
	.Timer_in(M_timerOutData),
	.dataType(M_MemDataType),
	.isSigned(M_MemOutSigned),
	
	.DM_out(M_DMOut)
);

assign m_data_addr = 
(M_externalInterruptResponse && interrupt) ? 32'h0000_7f20 : 
M_ALUOut;	//有外部中断则写0x7f20
assign m_data_wdata = 
(M_externalInterruptResponse && interrupt) ? 1 : 
(M_rtVal << {{m_data_addr[1:0]}, {3'b000}});	//需要取出对应的部分
assign m_inst_addr = M_PC;

assign m_int_addr = m_data_addr;
assign m_int_byteen = 
(M_externalInterruptResponse && interrupt) ? 4'b0001 : 4'b0000;

/*level W*/
W_M2Wreg w_m2wreg (
	.clk(clk),
	.reset(reset),
	.request(M_Request),

	.M_ALUOut(M_ALUOut),

	.M_DMOut(M_DMOut),

	.M_HIOut(M_HIOut),
	.M_LOOut(M_LOOut),
	.M_EPCOut(M_EPCOut),
	.M_CP0Out(M_CP0Out),

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
	.W_HIOut(W_HIOut),
	.W_LOOut(W_LOOut),
	.W_EPCOut(W_EPCOut),
	.W_CP0Out(W_CP0Out),

	.W_RegWrite(W_RegWrite),
	.W_RegWriteAddr(W_RegWriteAddr),
	.W_RegWriteDataSrc(W_RegWriteDataSrc),

	.W_Tnew(W_Tnew),

	.W_PC(W_PC),
	.W_PCwith4(W_PCwith4),
	.W_PCwith8(W_PCwith8),

	.W_new(W_new)
);

assign w_grf_we = W_RegWrite;
assign w_grf_addr = W_RegWriteAddr;
assign w_grf_wdata = W_RegWriteData;
assign w_inst_addr  = W_PC;

/*Process*/

wire [31:0] P_timerAddr, P_dataIn, P_timer0DataOut, P_timer1DataOut;
wire P_timer0WriteEnable, P_timer1WriteEnable, P_timer0IRQ, P_timer1IRQ;
//wire [31:0] M_timerOutData;
wire P_timerIRQOut0, P_timerIRQOut1;

TC timer_mode_0(
	.clk(clk),
	.reset(reset),
	.Addr(P_timerAddr[31:2]),
	.WE(P_timer0WriteEnable),
	.Din(P_dataIn),
	
	.Dout(P_timer0DataOut),
	.IRQ(P_timer0IRQ)
);

TC timer_mode_1(
	.clk(clk),
	.reset(reset),
	.Addr(P_timerAddr[31:2]),
	.WE(P_timer1WriteEnable),
	.Din(P_dataIn),
	
	.Dout(P_timer1DataOut),
	.IRQ(P_timer1IRQ)
);

Bridge bridge(
	.addrIn(m_data_addr),
	.dataIn(m_data_wdata),
	.byteEnable(m_data_byteen),
	.addrOut(P_timerAddr),
	.dataOut(P_dataIn),
	
	.timerWrite0(P_timer0WriteEnable),
	.timerWrite1(P_timer1WriteEnable),
	.timerIn0(P_timer0DataOut),
	.timerIn1(P_timer1DataOut),
	.timerIRQIn0(P_timer0IRQ),
	.timerIRQIn1(P_timer1IRQ),
	.timerIRQOut0(P_timerIRQOut0),
	.timerIRQOut1(P_timerIRQOut1),
	.timerOut(M_timerOutData)
);

endmodule
