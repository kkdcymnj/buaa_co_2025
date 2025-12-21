`timescale 1ns / 1ps
`include "constant.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:15:20 11/18/2025 
// Design Name: 
// Module Name:    E_MULT 
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
module E_MULT(
	input clk,
	input reset,
	input [31:0] A,
	input [31:0] B,
	input [3:0] MultOp,
	input [31:0] calcTime,	//运算周期数
	input request,

	output start,
	output [31:0] HI,
	output [31:0] LO,
	output busy
);
	 
reg [31:0] A_reg;
reg [31:0] B_reg;
reg [31:0] HI_reg;
reg [31:0] LO_reg;
reg [31:0] MultOp_reg;
reg [31:0] state = 0;

wire mult  = (MultOp == `mult_mult);
wire multu = (MultOp == `mult_multu);
wire div   = (MultOp == `mult_div);
wire divu  = (MultOp == `mult_divu);
wire mfhi  = (MultOp == `mult_mfhi);
wire mflo  = (MultOp == `mult_mflo);
wire mthi  = (MultOp == `mult_mthi);
wire mtlo  = (MultOp == `mult_mtlo);

assign HI = HI_reg;
assign LO = LO_reg;
assign busy = (state!=0);
assign start = ((state==0) && (mult || multu || div || divu));

//只要HI、LO寄存器没有被写入，有异常/中断时MDU就停止工作

always @(posedge clk) begin
	if(reset) begin
		A_reg<=0;
		B_reg<=0;
		HI_reg<=0;
		LO_reg<=0;
		state<=0;
		MultOp_reg<=`mult_undefined;
	end
	else if(!request) begin
		if(state==0) begin
			if(start) begin
				state<=calcTime;
				MultOp_reg<=MultOp;
				A_reg<=A;
				B_reg<=B;
			end
			else begin
				if(mthi) begin
					HI_reg <= A;
				end
				else if(mtlo) begin
					LO_reg <= A;
				end
			end
		end
		else if(state==1) begin	//最后一个周期出结果
			state <= state-1;
			case (MultOp_reg)
				`mult_mult:begin
					{HI_reg, LO_reg} <= $signed(A_reg) * $signed(B_reg);
				end
				`mult_multu:begin
					{HI_reg, LO_reg} <= A_reg * B_reg;
				end
				`mult_div:begin
					HI_reg <= $signed(A_reg) % $signed(B_reg);
					LO_reg <= $signed(A_reg) / $signed(B_reg);
				end
				`mult_divu:begin
					HI_reg <= A_reg % B_reg;
					LO_reg <= A_reg / B_reg;
				end
			endcase
		end
		else begin
			state<=state-1;	//模拟运算周期数
		end
	end
end

endmodule
