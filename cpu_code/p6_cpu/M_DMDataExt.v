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
	input clk,
	input reset,

	input [1:0] addrLow,
	input [31:0] DM_in,
	input [1:0] dataType,
	input isSigned,

	input new,
	input [31:0] rsVal,
	input [31:0] rtVal,
	input [4:0] rs,
	input [4:0] rt,

	output [31:0] DM_out,
	output [31:0] WD_out,
	output [4:0] RegWriteAddrSpecial
);
	 
//在这里建模一些奇奇怪怪的逻辑

wire [1:0] byte_sel = addrLow;
wire half_sel = addrLow[1];

wire [7:0] byte_content = DM_in[byte_sel*8 +: 8];
wire [15:0] half_content = DM_in[half_sel*16 +: 16];
wire [31:0] word_content = DM_in;

wire [31:0] DM_out_special;

wire [31:0] DM_out_normal = 
(!isSigned && dataType==`dm_BYTE) ? {{24'b0},{byte_content}}:
(!isSigned && dataType==`dm_half) ? {{16'b0},{half_content}}:
(isSigned && dataType==`dm_BYTE) ? {{24{byte_content[7]}},{byte_content}}:
(isSigned && dataType==`dm_half) ? {{16{half_content[15]}},{half_content}}:
word_content;

reg [31:0] WD_reg;
always @(posedge clk) begin
	/*if(new) begin
		WD<=DM_in;
	end*/
end

assign WD_out = WD_reg;

assign DM_out = (new) ? DM_out_special : DM_out_normal;

endmodule
