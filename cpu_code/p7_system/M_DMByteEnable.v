`timescale 1ns / 1ps
`include "constant.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:22:56 11/18/2025 
// Design Name: 
// Module Name:    M_DMByteEnable 
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
module M_DMByteEnable(
	input writeEnable,
	input request,
	input [1:0] dataType,
	input M_AdEL,
	input M_AdES,

	input [31:0] address,
	output [3:0] byteEnable
);
	 
assign byteEnable = 
(!writeEnable || request) ? 4'b0000:
(M_AdEL || M_AdES) ? 4'b0000:
(dataType == `dm_word) ? 4'b1111:
(dataType == `dm_half && address[1]==1'b0) ? 4'b0011:
(dataType == `dm_half && address[1]==1'b1) ? 4'b1100:
(dataType == `dm_BYTE && address[1:0]==2'b00) ? 4'b0001:
(dataType == `dm_BYTE && address[1:0]==2'b01) ? 4'b0010:
(dataType == `dm_BYTE && address[1:0]==2'b10) ? 4'b0100:
(dataType == `dm_BYTE && address[1:0]==2'b11) ? 4'b1000:
4'b0000;

endmodule
