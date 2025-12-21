module E_D2Ereg (
	input clk,
	input reset,
	input writeEnable,

	input [4:0] D_rs,
	input [4:0] D_rt,
	input [4:0] D_RegWriteAddr,
	input [31:0] D_rsVal,
	input [31:0] D_rtVal,
	input [31:0] D_extended,
	input [4:0] D_shamt,
	input [31:0] D_PC,
	input [31:0] D_PCwith4,
	input [31:0] D_PCwith8,
	input D_new,

	output reg [4:0] E_rs,
	output reg [4:0] E_rt,
	output reg [4:0] E_RegWriteAddr,
	output reg [31:0] E_rsVal,
	output reg [31:0] E_rtVal,
	output reg [31:0] E_extended,
	output reg [4:0] E_shamt,
	output reg [31:0] E_PC,
	output reg [31:0] E_PCwith4,
	output reg [31:0] E_PCwith8,
	output reg E_new,

	input [1:0] D_ALU_ASrc,
	input [1:0] D_ALU_BSrc,
	input [3:0] D_ALUOp,
	input D_MemWrite,
	input [1:0] D_MemDataType,
	input D_MemOutSigned,
	input D_RegWrite,
	input [1:0] D_RegWriteAddrSel,
	input [1:0] D_RegWriteDataSrc,

	output reg [1:0] E_ALU_ASrc,
	output reg [1:0] E_ALU_BSrc,
	output reg [3:0] E_ALUOp,
	output reg E_MemWrite,
	output reg [1:0] E_MemDataType,
	output reg E_MemOutSigned,
	output reg E_RegWrite,
	output reg [1:0] E_RegWriteAddrSel,
	output reg [1:0] E_RegWriteDataSrc,

	input [2:0] D_Tnew,

	output reg [2:0] E_Tnew
);

always @(posedge clk) begin
	if (reset || !writeEnable) begin
		E_rs <= 5'b0;
		E_rt <= 5'b0;
		E_RegWriteAddr <= 5'b0;
		E_rsVal <= 32'b0;
		E_rtVal <= 32'b0;
		E_extended<=32'b0;
		E_shamt <= 5'b0;
		E_PC <= 32'h0000_3000;
		E_PCwith4 <= 32'h0000_3004;
		E_PCwith8 <= 32'h0000_3008;
		E_new <= 0;

		E_ALU_ASrc <= 2'b0;
		E_ALU_BSrc <= 2'b0;
		E_ALUOp <= 4'b0;
		E_MemWrite <= 1'b0;
		E_MemDataType <= 2'b0;
		E_MemOutSigned <= 1'b0;
		E_RegWrite <= 1'b0;
		E_RegWriteAddrSel <= 2'b0;
		E_RegWriteDataSrc <= 2'b0;

		E_Tnew <= 3'b0;
	end
	else begin
		E_rs <= D_rs;
		E_rt <= D_rt;
		E_RegWriteAddr <= D_RegWriteAddr;
		E_rsVal <= D_rsVal;
		E_rtVal <= D_rtVal;
		E_extended <= D_extended;
		E_shamt <= D_shamt;
		E_PC<=D_PC;
		E_PCwith4 <= D_PCwith4;
		E_PCwith8 <= D_PCwith8;
		E_new <= D_new;

		E_ALU_ASrc <= D_ALU_ASrc;
		E_ALU_BSrc <= D_ALU_BSrc;
		E_ALUOp <= D_ALUOp;
		E_MemWrite <= D_MemWrite;
		E_MemDataType <= D_MemDataType;
		E_MemOutSigned <= D_MemOutSigned;
		E_RegWrite <= D_RegWrite;
		E_RegWriteAddrSel <= D_RegWriteAddrSel;
		E_RegWriteDataSrc <= D_RegWriteDataSrc;

		if (D_Tnew>0) begin
			E_Tnew <= D_Tnew - 1;
		end
		else begin
			E_Tnew <= D_Tnew;
		end
	end
end

endmodule // E_D2Ereg