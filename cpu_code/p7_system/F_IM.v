`timescale 1ns / 1ps
`include "constant.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:55:16 11/11/2025 
// Design Name: 
// Module Name:    F_IM 
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
module F_IM(
    input [31:0] currentPC,
	 input flush,
    output [31:0] Instr
    );
	 
reg [31:0] InstrMemory[0:`im_size];

initial begin
	$readmemh("code.txt",InstrMemory);
end

wire [31:0] index = (currentPC>>2)- 32'h0000_0c00;

assign Instr = 
(flush) ? 32'b0 : InstrMemory[index];

endmodule
