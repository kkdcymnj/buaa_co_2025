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
	input [31:0] A,	//rsVal
	input [31:0] B,	//rtVal
	input [3:0] MultOp,
	input [31:0] calcTime,	//运算周期数

	//预留新指令
	input new,

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
//wire new_command = (MultOp == `mult_special);

assign HI = HI_reg;
assign LO = LO_reg;
assign busy = (state!=0);
assign start = ((state==0) && (mult || multu || div || divu /*|| new_command*/));

/*
integer i;
integer cnt1=0;
integer cnt2=0;
reg [31:0] result_reg;
always @(*) begin
	if(start && new_command) begin
		cnt1=0;
		cnt2=0;
		for(i=0;i<=31;i=i+1) begin
			cnt1=cnt1+A[i];
		end
		for(i=0;i<=31;i=i+1) begin
			cnt2=cnt2+B[i];
		end
	end
	
	result_reg = (cnt1>cnt2) ? cnt1 : cnt2;
end
*/

always @(posedge clk) begin
	if(reset) begin
		A_reg<=0;
		B_reg<=0;
		HI_reg<=0;
		LO_reg<=0;
		state<=0;
		MultOp_reg<=`mult_undefined;
	end
	else begin
		if(state==0) begin
			if(start) begin
				state=calcTime;
				MultOp_reg=MultOp;
				A_reg=A;
				B_reg=B;
			end
			//结果输出，可能会要求交换 HI 和 LO 输出
			else begin
				if(mthi) begin
					HI_reg = A;
				end
				else if(mtlo) begin
					LO_reg = A;
				end
			end
		end
		else if(state==1) begin	//最后一个周期执行计算
			state = state-1;
			case (MultOp_reg)
				`mult_mult:begin
					{HI_reg, LO_reg} = $signed(A_reg) * $signed(B_reg);
				end
				`mult_multu:begin
					{HI_reg, LO_reg} = A_reg * B_reg;
				end
				`mult_div:begin
					HI_reg = $signed(A_reg) % $signed(B_reg);
					LO_reg = $signed(A_reg) / $signed(B_reg);
				end
				`mult_divu:begin
					HI_reg = A_reg % B_reg;
					LO_reg = A_reg / B_reg;
				end
				`mult_special:begin
					HI_reg = HI_reg;
					LO_reg = LO_reg;
				end
			endcase
		end
		else begin
			state=state-1;	//模拟运算周期数
		end
	end
end

endmodule
