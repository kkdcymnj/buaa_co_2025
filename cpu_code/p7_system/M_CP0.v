`timescale 1ns / 1ps
`include "constant.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:06:20 11/25/2025 
// Design Name: 
// Module Name:    M_CP0 
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
module M_CP0(
	input clk,
	input reset,
	input writeEnable,
	input interrupt,
	input [4:0] CP0Addr,
	input [31:0] CP0In,
	output [31:0] CP0Out,

	input [31:0] M_PC,
	input BDIn,//is delayed branch
	input [4:0] ExcCodeIn,
	input [5:0] HWInt,//hardware interrupt
	input EXLClear,
	output [31:0] EPCOut,
	output Request,
	output externalInterruptResponse
);
	 
reg [31:0] SR,Cause,EPC;

wire [5:0] IM = 
(writeEnable && CP0Addr == 12) ? CP0In[15:10]:
SR[15:10];
wire EXL = 
(writeEnable && CP0Addr == 12) ? CP0In[1]:
SR[1];
wire IE = 
(writeEnable && CP0Addr == 12) ? CP0In[0]:
SR[0];

wire BD = Cause[31];
wire [5:0] IP = Cause[15:10];
wire [4:0] ExcCode = Cause[6:2];

/*
wire Int  = (ExcCodeIn == `cp0_Int);
wire AdEL = (ExcCodeIn == `cp0_AdEL);
wire AdES = (ExcCodeIn == `cp0_AdES);
wire Syscall = (ExcCodeIn == `cp0_Syscall);
wire RI = (ExcCodeIn == `cp0_RI);
wire Ov = (ExcCodeIn == `cp0_Ov);
*/

wire INT = (!EXL) && (IE) && ((HWInt & IM) != 6'b000000);	//interrupt and interrupt is allowed
wire EXC = (!EXL) && (ExcCodeIn != 1 && ExcCodeIn != 0);
assign Request = (INT || EXC);
assign CP0Out = 
(CP0Addr == 12) ? SR :
(CP0Addr == 13) ? Cause :
(CP0Addr == 14) ? EPC : 
32'b0;

assign externalInterruptResponse =
(IE) && (!EXL) &&  (HWInt[2] & IM[2]);
//全局中断使能 | 不陷入内核态 | 有外部中断 | 中断使能

wire [31:0] VPC = (BDIn) ? M_PC-4 : M_PC;

assign EPCOut = 
(writeEnable && CP0Addr == 14) ? CP0In : 
(Request) ? VPC :
EPC;

initial begin
	SR<=0;
	Cause<=0;
	EPC<=0;
end

always @(posedge clk) begin
	if(reset) begin
		SR<=0;
		Cause<=0;
		EPC<=0;
	end
	else begin
		Cause[15:10]<= HWInt;
		//如果有外部中断、内部异常，CP0需要记录信息
		if(Request) begin
			SR[1] <= 1'b1;
			Cause[31] <= BDIn;
			
			if(INT) begin
				Cause[6:2] <= `cp0_Int;  // 硬件中断
			end 
			else begin
				Cause[6:2] <= ExcCodeIn;
			end
			
			EPC <= VPC;      
		end
		else if(writeEnable) begin
			case(CP0Addr)
				12:begin
					SR <= CP0In;
				end 
				13:begin
					Cause <= Cause; //Cause 不能被写入
				end
				14:begin
					EPC <= CP0In;
				end
			endcase
		end
		else begin
			if(EXLClear) begin	//eret
				SR[1] <= 1'b0;
			end
		end
	end
end

endmodule
