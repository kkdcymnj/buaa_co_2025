`timescale 1ns / 1ps

`define reg_addr_rd 0
`define reg_addr_rt 1
`define reg_addr_ra 2
`define reg_addr_special 3

`define npc_plus_4 0
`define npc_like_beq 1
`define npc_like_jal 2
`define npc_from_rs 3

`define alu_add 0
`define alu_sub 1
`define alu_or 2
`define alu_shift_b 3
`define alu_shift_16 4
`define alu_new_op 5

`define dm_word 0
`define dm_half 1
`define dm_BYTE 2

`define alu_a_rs 0
`define alu_a_rt 1

`define alu_b_rt 0
`define alu_b_extended 1
`define alu_b_shamt 2
`define alu_b_rs 3

`define reg_data_alu 0
`define reg_data_mem 1
`define reg_data_pc 2

`define dm_size 8192
`define im_size 8192
`define pc_base 32'h00003000

`define cmp_beq 0

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:43:22 11/11/2025 
// Design Name: 
// Module Name:    constant 
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