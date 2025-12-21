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

	//预留新指令的阻塞
	input E_new,
	input M_new,
	input [4:0] M_rs,
	input [4:0] M_rt,
	input [4:0] E_rs,
	input [4:0] E_rt,

	output stall
);

//对于新指令，只有W级的RegWrite是正确的
wire stall_from_E =
(E_RegWrite && (rs == E_RegWriteAddr && rs!=0) && (Tuse_rs < E_Tnew) ) ||
(E_RegWrite && (rt == E_RegWriteAddr && rt!=0) && (Tuse_rt < E_Tnew) ) ;

wire stall_from_M =
(M_RegWrite && (rs == M_RegWriteAddr && rs!=0) && (Tuse_rs < M_Tnew) ) ||
(M_RegWrite && (rt == M_RegWriteAddr && rt!=0) && (Tuse_rt < M_Tnew) );
//M_new==1时的阻塞要动动脑筋，不能再像E级一样无脑阻塞，否则会超时

assign stall = (stall_from_E || stall_from_M);

endmodule //D_stall