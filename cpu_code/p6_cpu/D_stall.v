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
	input E_busy,
	input E_start,

	//Ô¤ÁôĞÂÖ¸ÁîµÄ×èÈû
	input E_new,
	input M_new,
	input [4:0] M_rs,
	input [4:0] M_rt,
	input [4:0] E_rs,
	input [4:0] E_rt,

	output stall
);

wire stall_from_E =
(E_RegWrite && (rs == E_RegWriteAddr && rs!=0) && (Tuse_rs < E_Tnew) /*&& !E_new*/) ||
(E_RegWrite && (rt == E_RegWriteAddr && rt!=0) && (Tuse_rt < E_Tnew) /*&& !E_new*/) /*||
(E_RegWrite && ((rt == E_rt || rt == E_rs) && rt!=0) && (Tuse_rt < E_Tnew) && E_new) ||
(E_RegWrite && ((rs == E_rs || rs == E_rt) && rs!=0) && (Tuse_rs < E_Tnew) && E_new) */;

wire stall_from_M =
(M_RegWrite && (rs == M_RegWriteAddr && rs!=0) && (Tuse_rs < M_Tnew) /*&& !M_new*/) ||
(M_RegWrite && (rt == M_RegWriteAddr && rt!=0) && (Tuse_rt < M_Tnew) /*&& !M_new*/) /*||
(M_RegWrite && (rt == M_RegWriteAddrSpecial && rt!=0) && (Tuse_rt < M_Tnew) && M_new) ||
(M_RegWrite && (rs == M_RegWriteAddrSpecial && rs!=0) && (Tuse_rs < M_Tnew) && M_new) */;

wire stall_from_mult = 
D_doMult && (E_busy || E_start);

assign stall = (stall_from_E || stall_from_M || stall_from_mult);

endmodule //D_stall