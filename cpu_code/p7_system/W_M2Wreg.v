module W_M2Wreg (
    input clk,
    input reset,
	 input request,

    input [31:0] M_ALUOut,
	 input [31:0] M_HIOut,
	 input [31:0] M_LOOut,
    input [31:0] M_DMOut,
	 input [31:0] M_EPCOut,
	 input [31:0] M_CP0Out,
	 input M_RegWrite,
    input [4:0] M_RegWriteAddr,
    input [2:0] M_RegWriteDataSrc,
	 input [2:0] M_Tnew,
	 input [31:0] M_PC,
    input [31:0] M_PCwith4,
    input [31:0] M_PCwith8,
	 input M_new,

    output reg [31:0] W_ALUOut,
	 output reg [31:0] W_HIOut,
	 output reg [31:0] W_LOOut,
    output reg [31:0] W_DMOut,
	 output reg [31:0] W_EPCOut,
	 output reg [31:0] W_CP0Out,
	 output reg W_RegWrite,
    output reg [4:0] W_RegWriteAddr,
    output reg [2:0] W_RegWriteDataSrc,
	 output reg [2:0] W_Tnew,
	 output reg [31:0] W_PC,
    output reg [31:0] W_PCwith4,
    output reg [31:0] W_PCwith8,
	 output reg W_new
);

always @(posedge clk) begin
    if (reset || request) begin
        W_ALUOut <= 32'b0;
		  W_HIOut <= 32'b0;
		  W_LOOut <= 32'b0;
        W_DMOut <= 32'b0;
		  W_EPCOut <= 32'b0;
		  W_CP0Out <= 32'b0;
		  W_RegWrite<=0;
        W_RegWriteAddr <= 5'b0;
        W_RegWriteDataSrc <= 2'b0;
		  W_Tnew <= 3'b0;
		  if(!request) begin
			  W_PC <= 32'h0000_3000;
			  W_PCwith4 <= 32'h0000_3004;
			  W_PCwith8 <= 32'h0000_3008;
		  end
		  else begin
		     W_PC <= 32'h0000_4180;
			  W_PCwith4 <= 32'h0000_4184;
			  W_PCwith8 <= 32'h0000_4188;
		  end
		  
		  W_new <= 0;
    end
    else begin
        W_ALUOut <= M_ALUOut;
		  W_HIOut <= M_HIOut;
		  W_LOOut <= M_LOOut;
        W_DMOut <= M_DMOut;
		  W_EPCOut <= M_EPCOut;
		  W_CP0Out <= M_CP0Out;
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