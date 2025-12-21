module send(
	input [31:0] RegData,
	input [4:0] RegAddr,


	input [2:0] M_Tnew,
	input [4:0] M_RegWriteAddr,
	input [4:0] M_RegWriteAddrSpecial,
	input [31:0] M_RegWriteData,
	input M_RegWrite,

	input [2:0] W_Tnew,
	input [4:0] W_RegWriteAddr,
	input [31:0] W_RegWriteData,
	input W_RegWrite,

	//预留新指令
	input new,

	output [31:0] newRegData
);

//对于新指令，M_RegWrite的值不对

wire [2:0] sel = 
(RegAddr == M_RegWriteAddr && M_RegWriteAddr!=0 && M_RegWrite && M_Tnew==0 && new==0)? 2'b10:
(RegAddr == W_RegWriteAddr && W_RegWriteAddr!=0 && W_RegWrite && W_Tnew==0)? 2'b01:
2'b00;

assign newRegData = 
(sel == 2'b10) ? M_RegWriteData:
(sel == 2'b01) ? W_RegWriteData:
RegData;

endmodule