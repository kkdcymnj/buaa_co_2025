module M_E2Mreg (
	input clk,
	input reset,
	input request,

	input [4:0] E_rs,
	input [4:0] E_rt,
	input [31:0] E_rtVal,
	input [31:0] E_rsVal,
	input [31:0] E_ALUOut,
	input [31:0] E_HIOut,
	input [31:0] E_LOOut,
	input [4:0] E_RegWriteAddr,
	input [31:0] E_PC,
	input [31:0] E_PCwith4,
	input [31:0] E_PCwith8,
	input E_new,

	output reg [4:0] M_rs,
	output reg [4:0] M_rt,
	output reg [31:0] M_rtVal,
	output reg [31:0] M_rsVal,
	output reg [31:0] M_ALUOut,
	output reg [31:0] M_HIOut,
	output reg [31:0] M_LOOut,
	output reg [4:0] M_RegWriteAddr,
	output reg [31:0] M_PC,
	output reg [31:0] M_PCwith4,
	output reg [31:0] M_PCwith8,
	output reg M_new,

	input E_MemWrite,
	input [1:0] E_MemDataType,
	input E_MemOutSigned,
	input E_RegWrite,
	input [1:0] E_RegWriteAddrSel,
	input [2:0] E_RegWriteDataSrc, 

	output reg M_MemWrite,
	output reg [1:0] M_MemDataType,
	output reg M_MemOutSigned,
	output reg M_RegWrite,
	output reg [1:0] M_RegWriteAddrSel,
	output reg [2:0] M_RegWriteDataSrc, 

	input [2:0] E_Tnew,
	output reg [2:0] M_Tnew,

	input E_BD,
	input E_RI,
	output reg M_BD,
	output reg M_RI,

	input E_handleException,
	input E_Syscall,
	input E_cp0WriteEnable,
	input [4:0] E_cp0Addr,
	output reg M_handleException,
	output reg M_Syscall,
	output reg M_cp0WriteEnable,
	output reg [4:0] M_cp0Addr,

	input E_Ov,
	output reg M_Ov,

	input E_PCOutOfRange,
	input E_PCfalse,
	output reg M_PCOutOfRange,
	output reg M_PCfalse,

	input [4:0] E_exceptionCode,
	output reg [4:0] M_exceptionCodeTemp
);

always @(posedge clk) begin
	if (reset || request) begin
		M_rs <= 5'b0;
		M_rt <= 5'b0;
		M_rtVal <= 32'b0;
		M_ALUOut <= 32'b0;
		M_HIOut <= 32'b0;
		M_LOOut <= 32'b0;
		M_RegWriteAddr <= 5'b0;

		if(reset) begin
			M_PC <= 32'h0000_3000;
			M_PCwith4 <= 32'h0000_3004;
			M_PCwith8 <= 32'h0000_3008;
		end
		else if(request) begin
			M_PC <= 32'h0000_4180;
			M_PCwith4 <= 32'h0000_4184;
			M_PCwith8 <= 32'h0000_4188;
		end

		M_new <= 0;

		M_MemWrite <= 1'b0;
		M_MemDataType <= 2'b0;
		M_MemOutSigned <= 1'b0;
		M_RegWrite <= 1'b0;
		M_RegWriteAddrSel <= 2'b0;
		M_RegWriteDataSrc <= 2'b0;

		M_Tnew <= 3'b0;

		M_BD <= 1'b0;
		M_RI <= 1'b0;		  
		M_handleException <= 1'b0;
		M_Syscall <= 1'b0;
		M_cp0WriteEnable <= 1'b0;
		M_cp0Addr <= 5'b0;

		M_Ov <= 1'b0;

		M_PCOutOfRange<=1'b0;
		M_PCfalse<=1'b0;

		M_exceptionCodeTemp<=5'b1;
	end
	else begin
		M_rs <= E_rs;
		M_rt <= E_rt;
		M_rtVal <= E_rtVal;
		M_ALUOut <= E_ALUOut;
		M_HIOut <= E_HIOut;
		M_LOOut <= E_LOOut;
		M_RegWriteAddr <= E_RegWriteAddr;
		M_PC <= E_PC;
		M_PCwith4 <= E_PCwith4;
		M_PCwith8 <= E_PCwith8;
		M_new <= E_new;

		M_MemWrite <= E_MemWrite;
		M_MemDataType <= E_MemDataType;
		M_MemOutSigned <= E_MemOutSigned;
		M_RegWrite <= E_RegWrite;
		M_RegWriteAddrSel <= E_RegWriteAddrSel;
		M_RegWriteDataSrc <= E_RegWriteDataSrc;

		if(E_Tnew > 0) begin
			M_Tnew <= E_Tnew - 1;
		end
		else begin
			M_Tnew <= E_Tnew;
		end

		M_BD <= E_BD;
		M_RI <= E_RI;
		M_handleException <= E_handleException;
		M_Syscall <= E_Syscall;
		M_cp0WriteEnable <= E_cp0WriteEnable;
		M_cp0Addr <= E_cp0Addr;

		M_Ov <= E_Ov;

		M_PCOutOfRange<=E_PCOutOfRange;
		M_PCfalse<=E_PCfalse;

		M_exceptionCodeTemp<=E_exceptionCode;
	end
end

endmodule // M_E2Mreg