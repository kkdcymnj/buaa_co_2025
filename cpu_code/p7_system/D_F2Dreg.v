`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:01:15 11/11/2025 
// Design Name: 
// Module Name:    D_F2Dreg 
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
module D_F2Dreg(
	input clk,
	input reset,
	input [31:0] F_PC,
	input [31:0] F_Instr,
	input D_stall,
	input request,
	input F_PCOutOfRange,
	input F_PCfalse,

	output reg [31:0] D_PC,
	output reg [31:0] D_PCwith4,
	output reg [31:0] D_PCwith8,
	output reg [31:0] D_Instr,
	output reg D_PCOutOfRange,
	output reg D_PCfalse,

	input [4:0] F_exceptionCode,
	output reg [4:0] D_exceptionCodeTemp,
	
	input F_BD,
	output reg D_BD
);
	 
wire stall = (D_stall);
	 
always @(posedge clk) begin
	if(reset || request) begin
		if(reset) begin
			D_PC<=32'h0000_3000;
			D_PCwith4<=32'h0000_3004;
			D_PCwith8<=32'h0000_3008;
		end
		else if(request) begin
			D_PC<=32'h0000_4180;
			D_PCwith4<=32'h0000_4184;
			D_PCwith8<=32'h0000_4188;
		end
		D_Instr<=0;
		D_PCOutOfRange<=1'b0;
		D_PCfalse<=1'b0;
		D_exceptionCodeTemp<=5'b1;
		D_BD<=1'b0;
	end
	else if(!stall) begin
		D_PC<=F_PC;
		D_PCwith4<=F_PC+4;
		D_PCwith8<=F_PC+8;
		D_Instr<=F_Instr;
		D_PCOutOfRange <= F_PCOutOfRange;
		D_PCfalse <= F_PCfalse;
		D_exceptionCodeTemp<=F_exceptionCode;
		D_BD<=F_BD;
	end
	//$display("time: %d, current PC: %h, Instr: %h",$time, D_PC, D_Instr);
end


endmodule
