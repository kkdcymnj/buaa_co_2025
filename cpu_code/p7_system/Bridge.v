`timescale 1ns / 1ps
`include "constant.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:37:30 11/25/2025 
// Design Name: 
// Module Name:    Bridge 
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
module Bridge(
	input [31:0] addrIn,
	input [31:0] dataIn,
	input [3:0] byteEnable,	//interact with DM
	output [31:0] addrOut,
	output [31:0] dataOut,
	
	//interact with timer
	input [31:0] timerIn0,
	input [31:0] timerIn1,
	input timerIRQIn0,
	input timerIRQIn1,
	output [31:0] timerOut,
	output timerWrite0,
	output timerWrite1,
	output timerIRQOut0,
	output timerIRQOut1
    );

//get data from DM
assign dataOut = dataIn;
assign addrOut = addrIn;

//get data from Timer
assign timerIRQOut0 = timerIRQIn0;
assign timerIRQOut1 = timerIRQIn1;
assign timerWrite0 = (addrIn >= 32'h00007f00 && addrIn <= 32'h00007f0b && byteEnable != 4'b0000);
assign timerWrite1 = (addrIn >= 32'h00007f10 && addrIn <= 32'h00007f1b && byteEnable != 4'b0000);
assign timerOut = 
(addrIn >= 32'h00007f00 && addrIn <= 32'h00007f0b) ? timerIn0:
(addrIn >= 32'h00007f10 && addrIn <= 32'h00007f1b) ? timerIn1:
0;

endmodule
