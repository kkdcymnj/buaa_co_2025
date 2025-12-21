module D_stall (
	input [2:0] Tuse_rs,
	input [2:0] Tuse_rt,
	input [2:0] E_Tnew,
	input [2:0] M_Tnew,

	input [4:0] rs,
	input [4:0] rt,
	input [4:0] E_RegWriteAddr,
	input [4:0] M_RegWriteAddr,
	input [4:0] M_RegWriteAddrSpecial,
	input E_RegWrite,
	input M_RegWrite,

	input D_doMult,
	input E_start,
	input E_busy,

	//预留新指令的阻塞
	input E_new,
	input M_new,
	input [4:0] M_rs,
	input [4:0] M_rt,
	input [4:0] E_rs,
	input [4:0] E_rt,

	//当mfc0修改EPC，D级的eret要阻塞
	input D_handleException,
	input M_cp0WriteEnable,
	input [4:0] M_cp0Addr,
	input E_cp0WriteEnable,
	input [4:0] E_cp0Addr,

	output stall
);

wire stall_from_E =
(E_RegWrite && (rs == E_RegWriteAddr && rs!=0) && (Tuse_rs < E_Tnew)) ||
(E_RegWrite && (rt == E_RegWriteAddr && rt!=0) && (Tuse_rt < E_Tnew)) /*||
(E_RegWrite && ((rt == E_rt || rt == E_rs) && rt!=0) && (Tuse_rt < E_Tnew) && E_new) ||
(E_RegWrite && ((rs == E_rs || rs == E_rt) && rs!=0) && (Tuse_rs < E_Tnew) && E_new) */;

wire stall_from_M =
(M_RegWrite && (rs == M_RegWriteAddr && rs!=0) && (Tuse_rs < M_Tnew)) ||
(M_RegWrite && (rt == M_RegWriteAddr && rt!=0) && (Tuse_rt < M_Tnew)) /*||
(M_RegWrite && (rt == M_RegWriteAddrSpecial && rt!=0) && (Tuse_rt < M_Tnew) && M_new) ||
(M_RegWrite && (rs == M_RegWriteAddrSpecial && rs!=0) && (Tuse_rs < M_Tnew) && M_new) */;

wire stall_from_mult =
D_doMult & (E_start | E_busy);

wire stall_from_CP0 = 
(D_handleException) && 
((M_cp0WriteEnable && M_cp0Addr==5'd14) || (E_cp0WriteEnable && E_cp0Addr==5'd14));

assign stall = (stall_from_E || stall_from_M || stall_from_mult || stall_from_CP0);

endmodule //D_stall