`timescale 1ns / 1ps

`define ext_unsigned 0
`define ext_signed 1
`define ext_special 2

`define reg_addr_rd 0
`define reg_addr_rt 1
`define reg_addr_ra 2
`define reg_addr_special 3

`define npc_plus_4 0
`define npc_like_beq 1
`define npc_like_jal 2
`define npc_from_rs 3
`define npc_special 4

`define alu_add 0
`define alu_sub 1
`define alu_or 2
`define alu_and 3
`define alu_slt 4
`define alu_sltu 5
`define alu_shift_b 6
`define alu_shift_16 7
`define alu_new_op 8

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
`define reg_data_hi 3
`define reg_data_lo 4
`define reg_data_special 5

`define dm_size 8192
`define im_size 8192
`define pc_base 32'h0000_3000

`define cmp_beq 0
`define cmp_bne 1
`define cmp_special 2

`define mult_mult 0
`define mult_multu 1
`define mult_div 2
`define mult_divu 3
`define mult_mfhi 4
`define mult_mflo 5
`define mult_mthi 6
`define mult_mtlo 7
`define mult_special 8
`define mult_undefined 9

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