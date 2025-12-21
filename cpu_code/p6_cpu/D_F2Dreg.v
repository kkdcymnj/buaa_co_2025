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

	output reg [31:0] D_PC,
	output reg [31:0] D_PCwith4,
	output reg [31:0] D_PCwith8,
	output reg [31:0] D_Instr
);
	 
wire writeEnable = ~D_stall;
	 
always @(posedge clk) begin
	if(reset) begin
		D_PC<=32'h0000_3000;
		D_PCwith4<=32'h0000_3004;
		D_PCwith8<=32'h0000_3008;
		D_Instr<=0;
	end
	else if(writeEnable) begin
		D_PC<=F_PC;
		D_PCwith4<=F_PC+4;
		D_PCwith8<=F_PC+8;
		D_Instr<=F_Instr;
	end
	//阻塞时，D级PC和Instr都不能变
end


endmodule
