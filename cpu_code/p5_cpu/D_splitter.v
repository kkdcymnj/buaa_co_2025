`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:05:27 11/11/2025 
// Design Name: 
// Module Name:    D_splitter 
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
module D_splitter(
	input [31:0] Instr,
	output [5:0] opCode,
	output [5:0] funct,
	output [4:0] rs,
	output [4:0] rt,
	output [4:0] rd,
	output [4:0] shamt,
	output [15:0] immediate16,
	output [25:0] immediate26
);

assign funct = Instr[5:0];
assign shamt = Instr[10:6];
assign rd = Instr[15:11];
assign rt = Instr[20:16];
assign rs = Instr[25:21];
assign opCode = Instr[31:26];
assign immediate16 = Instr[15:0];
assign immediate26 = Instr[25:0];

endmodule
