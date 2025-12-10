import random
import os
import command_adder

reg_size = 32
mem_size = 4096
max_immediate = 2 ** 16 - 1
min_immediate = -2 ** 15

def generate_loop_start(loop_var, label_num, cycle_num, instr_list):
    # 初始化loop_var
    init_choice = random.randint(0, 1)
    if init_choice == 0:
        instr_list.append(f"ori ${loop_var},$0,0")
    else:
        instr_list.append(f"lui ${loop_var},0")

    # 添加标签
    cur_label = f"label{label_num}"

    instr_list.append(f"ori $20,$0,{cycle_num}")
    instr_list.append(f"sw $20,48($0)")
    instr_list.append(f"ori $22,$0,44")
    instr_list.append(f"sw $22,56($0)")  # 记录了 $31 存储地址
    instr_list.append(f"jal {cur_label}_begin")
    instr_list.append(f"sw $31,44($0)")
    instr_list.append(f"nop")

    instr_list.append(f"{cur_label}_begin:")

    get_jal_choice = random.randint(0, 1)
    if get_jal_choice == 0:
        instr_list.append(f"add $22,$0,$31")
    else:
        instr_list.append(f"lw $20,56($0)")
        instr_list.append(f"lw $22,0($20)")
    instr_list.append(f"sw $22,52($0)")

def generate_loop_body (loop_var, body_len, allowed_instr, generate_prop, instr_list):
    # 循环体
    mult_mark = 0
    for i in range(body_len):
        command_adder.generate_single_command(allowed_instr, generate_prop, instr_list, loop_var, mult_mark)

def generate_loop_end(loop_var, label_num, instr_list):
    # 添加标签
    cur_label = f"label{label_num}"

    # 循环尾部
    instr_list.append(f"ori $22,$0,1")
    instr_list.append(f"add ${loop_var},${loop_var},$22")
    instr_list.append(f"lw $22,48($0)")
    instr_list.append(f"beq ${loop_var},$22,{cur_label}_end")
    if random.random() < 0.5:
        instr_list.append(f"nop")
    else:
        command_adder.generate_error_command(instr_list)

    jr_choice = random.randint(0, 2)
    match jr_choice:
        case 0:
            instr_list.append(f"lw $22,52($0)")
            instr_list.append(f"jr $22")
        case 1:
            instr_list.append(f"lw $21,52($0)")
            instr_list.append(f"ori $20,$0,1")
            instr_list.append(f"sub $21,$21,$20")
            instr_list.append(f"add $22,$21,$20")
            instr_list.append(f"jr $22")
        case 2:
            instr_list.append(f"lw $21,52($0)")
            instr_list.append(f"ori $20,$21,0")
            instr_list.append(f"jr $20")

    if random.random() < 0.5:
        instr_list.append(f"nop")
    else:
        command_adder.generate_error_command(instr_list)

    instr_list.append(f"{cur_label}_end:")

    # 一定概率进行大幅度跳转
    choice = random.randint(0, 1)
    if choice == 0:
        instr_list.append(f"lui $26,0")
        instr_list.append(f"ori $27,$0,1")
        instr_list.append(f"jal common_block")
        instr_list.append(f"nop")

def generate_loop(loop_var, cycle_num, body_len, label_num,
                      allowed_instr, generate_prop, instr_list):
    generate_loop_start(loop_var, label_num, cycle_num, instr_list)
    generate_loop_body(loop_var, body_len, allowed_instr, generate_prop, instr_list)
    generate_loop_end(loop_var, label_num, instr_list)

def load_exception_handler(instr_list):
    with open("exception_handler//handler.asm", 'r', encoding='GB2312') as f:
        lines = f.readlines()

    for line in lines:
        instr_list.append(line.rstrip('\n'))


def generate_case(num_of_loops, loop_size_max, instr_list, instr_option, prop):
    # data字段
    instr_list.append(".data")
    instr_list.append("array:.space 8192")

    instr_list.append(".text")
    instr_list.append("ori $gp,$0,0x1800")
    instr_list.append("ori $sp,$0,0x2ffc")
    instr_list.append("ori $10,$0,0x1c01")
    instr_list.append("mtc0 $10,$12")
    instr_list.append("mfc0 $10,$12")
    instr_list.append("mfc0 $10,$13")
    instr_list.append("mfc0 $10,$14")

    # 随机初始化
    for i in range(reg_size):
        if i == 0 or 2 <= i <= 19:
            immediate = random.randint(max_immediate // 2, max_immediate)
            instr_list.append(f"lui ${i},{immediate}")
            immediate = random.randint(max_immediate // 4, max_immediate // 2)
            instr_list.append(f"ori ${i},${i},{immediate}")

    # 内存初始化
    addr = 0
    for i in range(reg_size):
        if i == 0 or 2 <= i <= 19:
            instr_list.append(f"sw ${i},{addr}($0)")
            addr += 4

    # 开始生成循环
    for i in range(num_of_loops):
        loop_size = random.randint(loop_size_max // 2, loop_size_max)
        # cycles = random.randint(1, 3)
        cycles = 1
        var = random.randint(11, 15)  # 循环变量
        generate_loop(loop_var=var, cycle_num=cycles, body_len=loop_size, label_num=i,
                      allowed_instr=instr_option, generate_prop=prop, instr_list=instr_list)

    instr_list.append(f"ori $21,32767")
    instr_list.append(f"ori $22,$0,32767")

    # 大范围跳转测试
    instr_list.append(f"common_block:")
    instr_list.append(f"beq $21,$22,end")
    instr_list.append(f"nop")
    instr_list.append(f"jr $31")
    instr_list.append(f"nop")

    load_exception_handler(instr_list)

    # 程序结束
    instr_list.append(f"end:")
    instr_list.append(f"bne $0,$0,common_block")
    instr_list.append(f"nop")

    return '\n'.join(instr_list)


def generate_multiple_cases(num_of_cases, num_of_loops, loop_size_max, instr_option, prop):
    test_case_list = []
    for i in range(num_of_cases):
        instructions = []
        test_case_list.append(generate_case(num_of_loops, loop_size_max, instructions, instr_option, prop))
    return test_case_list


def create_test(n, num_of_loops, loop_size_max, instr_option, prop):
    test_cases = generate_multiple_cases(n, num_of_loops, loop_size_max, instr_option, prop)
    os.makedirs("samples", exist_ok=True)

    # 样例保存到文件
    for i, test_case in enumerate(test_cases, 1):
        with open(f'samples\\test_case_{i}.txt', 'w', encoding='utf-8') as f:
            f.write(test_case)
        print(f"样例 {i} 已经保存到文件 test_case_{i}.txt")

