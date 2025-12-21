module W_M2Wreg (
	input clk,
	input reset,

	input [31:0] M_ALUOut,
	input [31:0] M_DMOut,
	input M_RegWrite,
	input [4:0] M_RegWriteAddr,
	input [1:0] M_RegWriteDataSrc,
	input [2:0] M_Tnew,
	input [31:0] M_PC,
	input [31:0] M_PCwith4,
	input [31:0] M_PCwith8,
	input M_new,

	output reg [31:0] W_ALUOut,
	output reg [31:0] W_DMOut,
	output reg W_RegWrite,
	output reg [4:0] W_RegWriteAddr,
	output reg [1:0] W_RegWriteDataSrc,
	output reg [2:0] W_Tnew,
	output reg [31:0] W_PC,
	output reg [31:0] W_PCwith4,
	output reg [31:0] W_PCwith8,
	output reg W_new
);

always @(posedge clk) begin
	if (reset) begin
		W_ALUOut <= 32'b0;
		W_DMOut <= 32'b0;
		W_RegWrite<=0;
		W_RegWriteAddr <= 5'b0;
		W_RegWriteDataSrc <= 2'b0;
		W_Tnew <= 3'b0;
		W_PC <= 32'h0000_3000;
		W_PCwith4 <= 32'h0000_3004;
		W_PCwith8 <= 32'h0000_3008;
		W_new <= 0;
	end
	else begin
		W_ALUOut <= M_ALUOut;
		W_DMOut <= M_DMOut;
		W_RegWrite<=M_RegWrite;
		W_RegWriteAddr <= M_RegWriteAddr;
		W_RegWriteDataSrc <= M_RegWriteDataSrc;
		W_PC <= M_PC;
		W_PCwith4 <= M_PCwith4;
		W_PCwith8 <= M_PCwith8;
		W_new <= M_new;

		if(M_Tnew > 0) begin
			W_Tnew <= M_Tnew-1;
		end
		else begin
			W_Tnew <= M_Tnew;
		end
	end

	//$display("level W: writeReg: %d",W_RegWrite);
end

endmodule // W_M2Wreg