`timescale 1ns / 1ps
`include "constant.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:14:11 11/18/2025 
// Design Name: 
// Module Name:    M_DMDataExt 
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
module M_DMDataExt(
	input [31:0] addr,
	input [31:0] DM_in,
	input [31:0] Timer_in,
	input [1:0] dataType,
	input isSigned,
	output [31:0] DM_out
);

wire [1:0] addrLow = addr[1:0];

wire [1:0] byte_sel = addrLow;
wire half_sel = addrLow[1];

wire [7:0] byte_content = DM_in[byte_sel*8 +: 8];
wire [15:0] half_content = DM_in[half_sel*16 +: 16];

assign DM_out = 
((addr >= 32'h0000_7f00 && addr <= 32'h0000_7f0b) || 
		(addr >= 32'h0000_7f10 && addr <= 32'h0000_7f1b)) ? Timer_in:	//此时读的是计时器数据
(!isSigned && dataType==`dm_BYTE) ? {{24'b0},{byte_content}}:
(!isSigned && dataType==`dm_half) ? {{16'b0},{half_content}}:
(isSigned && dataType==`dm_BYTE) ? {{24{byte_content[7]}},{byte_content}}:
(isSigned && dataType==`dm_half) ? {{16{half_content[15]}},{half_content}}:
DM_in;

endmodule
