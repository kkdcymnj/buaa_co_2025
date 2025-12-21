`define addr_begin 0
`define addr_end 32'h10000
`define base 16'h0c00

module IFU (
	input clk,
	input reset,
	input doBranch,
	input [15:0] offset,
	input jump,
	input [25:0] instr_index,
	input jumpReturn,
	input [31:0] PC_from_jr,

	output [5:0] funct,
	output [4:0] s,
	output [4:0] rd,
	output [4:0] rt,
	output [4:0] rs,
	output [5:0] op,
	output [15:0] immediate16,
	output [25:0] immediate26,
	output reg [31:0] currentPC
);

reg [31:0] instr_save[`addr_begin:`addr_end];

//decode
wire [31:0] instr = instr_save[currentPC[17:2] - `base];
assign funct = instr[5:0];
assign s = instr[10:6];
assign rd = instr[15:11];
assign rt = instr[20:16];
assign rs = instr[25:21];
assign op = instr[31:26];
assign immediate16 = instr[15:0];
assign immediate26 = instr[25:0];

integer i;
initial begin
	currentPC <= 32'h0000_3000;
	$readmemh("code.txt", instr_save);
end

always @(posedge clk ) begin
	//$display("current instr: %h, current PC£º%h",instr, currentPC);
	if (reset) begin
	  currentPC <= 32'h0000_3000;
	end
	else begin
	  currentPC <= 
	  (doBranch) ? currentPC + 4 + {{14{offset[15]}},{offset},{2'b00}}://beq
	  (jump) ? {{currentPC[31:28]}, {instr_index}, {2'b00}}://j and jal
	  (jumpReturn) ? PC_from_jr://jr
	  currentPC + 4;//others
	  //$
	end
end

endmodule //ifu