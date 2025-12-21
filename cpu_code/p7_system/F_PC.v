`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:54:36 11/11/2025 
// Design Name: 
// Module Name:    F_PC 
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
module F_PC(
	input clk,
	input reset,
	input [31:0] nextPC,

	output reg [31:0] currentPC
);
	 
initial begin	
	currentPC<=32'h0000_3000;
end
	 
always @(posedge clk) begin
	if(reset) begin
		currentPC<=32'h0000_3000;
	end
	else begin
		currentPC<=nextPC;
	end
end


endmodule
