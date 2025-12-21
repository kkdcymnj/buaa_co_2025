//reg_dst
`define rt 0
`define rd 1
`define ra 2
//reg_data_source
`define alu 0
`define mem 1 
`define pc 2 
`define special 3

module mips (
	input clk,
	input reset
);

wire [31:0] current_pc,next_pc,rd1,rd2,extended,alu_result,mem_data,special_data,mem_out_alter;
wire [15:0] immediate_16;
wire [25:0] immediate_26;
wire [5:0] op_code,funct;
wire [4:0] rs,rt,rd,shamt;
wire [3:0] alu_op;
wire [1:0] reg_dst,reg_data_source,data_type;
wire branch,jump,jump_return,ext_op,zero_flag,mem_write,mem_read,alu_source,reg_write;
wire new_order;

IFU Instruction_taker(
	.clk(clk),
	.reset(reset),
	.doBranch(branch && zero_flag),
	.offset(immediate_16),
	.jump(jump),
	.instr_index(immediate_26),
	.jumpReturn(jump_return),
	.PC_from_jr(rd1),

	.op(op_code),
	.funct(funct),
	.s(shamt),
	.rd(rd),
	.rt(rt),
	.rs(rs),
	.immediate16(immediate_16),
	.immediate26(immediate_26),
	.currentPC(current_pc)
);

CTRL Controller(
	.op(op_code),
	.func(funct),

	.RegDst(reg_dst),
	.ALUSrc(alu_source),
	.RegDataSrc(reg_data_source),
	.RegWrite(reg_write),
	.MemWrite(mem_write),
	.MemRead(mem_read),
	.Branch(branch),
	.ExtOp(ext_op),
	.ALUOp(alu_op),
	.JumpReturn(jump_return),
	.Jump(jump),
	.dataType(data_type),
	.newOrder(new_order)
);

EXT Immediate_Extend(
	.immediate(immediate_16),
	.extOp(ext_op),

	.result(extended)
);

wire [4:0] exactA3 = 
(reg_dst == `ra) ? 31:
(reg_dst == `rd) ? rd:
rt;
wire [31:0] exactGrfData = 
(reg_data_source == `pc) ? current_pc + 4:
(reg_data_source == `mem) ? mem_data:
(reg_data_source == `special) ? special_data:
alu_result;

GRF Register_File(
	.clk(clk),
	.reset(reset),
	.write_enable(reg_write),
	.A1(rs),
	.A2(rt),
	.A3(exactA3),
	.write_data(exactGrfData),
	.currentPC(current_pc),

	.RD1(rd1),
	.RD2(rd2)
);

wire [31:0] numB = (alu_source) ? extended : rd2;
ALU Operator(
	.A(rd1),
	.B(numB),
	.S(shamt),
	.op(alu_op),

	.result(alu_result),
	.zeroFlag(zero_flag)
);

DM Data_Memory(
	.clk(clk),
	.reset(reset),
	.write_enable(mem_write),
	.read_enable(mem_read),
	.dataType(data_type),
	.address(alu_result),
	.write_data(rd2),
	.currentPC(current_pc),

	.out_data(mem_data),
	.out_alter(mem_out_alter)
);
endmodule //mips