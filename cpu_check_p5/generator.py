import array
import random

from Demos.mmapfile_demo import offset
from sympy.physics.units import current

from sympy.physics.control import ramp_response_numerical_data

from networkx.classes import is_empty
from sympy.codegen.cnodes import sizeof
from xeger import Xeger
import os

reg_size = 32
mem_size = 4096
max_immediate = 2 ** 16 - 1
min_immediate = -2 ** 15

supported_instr = ["add", "sub", "ori", "lw", "sw", "beq", "nop", "lui", "jal", "jr"]
instr_in_body = ["add", "sub", "lw", "ori", "sw", "nop", "lui"]  # 为了生成方便，循环主体内不作跳转
instr_probs = [0.15, 0.15, 0.15, 0.15, 0.15, 0.1, 0.15]


def generate_loop(loop_var, cycle_num, body_len, label_num, allowed_instr, generate_prop, instr_list):
    # 初始化loop_var
    init_choice = random.randint(0, 1)
    if init_choice == 0:
        instr_list.append(f"ori ${loop_var},$0,0")
    else:
        instr_list.append(f"lui ${loop_var},0")

    # 添加标签
    cur_label = f"label{label_num}"

    instr_list.append(f"ori $25,$0,{cycle_num}")
    instr_list.append(f"sw $25,48($0)")
    instr_list.append(f"ori $27,$0,44")
    instr_list.append(f"sw $27,56($0)") #记录了 $31 存储地址
    instr_list.append(f"jal {cur_label}_begin")
    instr_list.append(f"sw $31,44($0)")
    instr_list.append(f"nop")

    instr_list.append(f"{cur_label}_begin:")

    get_jal_choice = random.randint(0, 1)
    if get_jal_choice == 0:
        instr_list.append(f"add $27,$0,$31")
    else:
        instr_list.append(f"lw $25,56($0)")
        instr_list.append(f"lw $27,0($25)")
    instr_list.append(f"sw $27,52($0)")
    # 循环体
    for i in range(body_len):
        # 选择需要操作的寄存器
        choice_range = [i for i in range(2, 6) if i != loop_var]
        rs = random.choice(choice_range)
        rt = random.choice(choice_range)
        rd = random.choice(choice_range)

        cur_instr = random.choices(allowed_instr, generate_prop)[0]
        match cur_instr:
            case "add" | "sub":
                instr_list.append(f"{cur_instr} ${rd},${rs},${rt}")
            case "lw" | "sw":
                '''
                while True:
                    address = random.randint(0, mem_size)
                    final_address = random.randint(0, mem_size)
                    if address % 4 == 0 and final_address % 4 == 0:
                        or_instance = final_address - address
                        break
                '''
                while True:
                    address = random.randint(0, 8)
                    if address % 4 == 0:
                        break
                #instr_list.append(f"ori ${26},${0},{or_instance}")
                instr_list.append(f"{cur_instr} ${rt},{address}(${0})")
            case "ori":
                # choice = random.randint(0, 1)
                choice = 0
                if choice == 0:
                    immediate = random.randint(max_immediate // 2, max_immediate)
                else:
                    immediate = random.randint(min_immediate, min_immediate // 2)
                instr_list.append(f"ori ${rt},${rs},{immediate}")
            case "nop":
                instr_list.append(f"nop")
            case "lui":
                choice = 0
                if choice == 0:
                    immediate = random.randint(max_immediate // 2, max_immediate)
                else:
                    immediate = random.randint(min_immediate, min_immediate // 2)
                instr_list.append(f"lui ${rt},{immediate}")

    # 循环尾部
    instr_list.append(f"ori ${27},$0,1")
    instr_list.append(f"add ${loop_var},${loop_var},${27}")
    #instr_list.append(f"ori ${27},$0,{cycle_num}")
    instr_list.append(f"lw $27,48($0)")
    instr_list.append(f"beq ${loop_var},${27},{cur_label}_end")
    instr_list.append(f"nop")

    jr_choice = random.randint(0, 2)
    match jr_choice:
        case 0:
            instr_list.append(f"lw $27,52($0)")
            instr_list.append(f"jr $27")
        case 1:
            instr_list.append(f"lw $26,52($0)")
            instr_list.append(f"ori $25,$0,1")
            instr_list.append(f"sub $26,$26,$25")
            instr_list.append(f"add $27,$26,$25")
            instr_list.append(f"jr $27")
        case 2:
            instr_list.append(f"lw $26,52($0)")
            instr_list.append(f"ori $25,$26,0")
            instr_list.append(f"jr $25")


    instr_list.append(f"nop")
    instr_list.append(f"{cur_label}_end:")

    # 一定概率进行大幅度跳转
    choice = random.randint(0, 1)
    if choice == 0:
        instr_list.append(f"lui $26,0")
        instr_list.append(f"ori $27,$0,1")
        instr_list.append(f"jal common_block")
        instr_list.append(f"nop")


def generate_case(num_of_loops, loop_size_max, instr_list, instr_option, prop):
    # data字段
    instr_list.append(".data")
    instr_list.append("array:.space 8192")
    instr_list.append(".text")

    # 随机初始化
    for i in range(reg_size):
        if i == 0 or 2 <= i <= 26:
            immediate = random.randint(max_immediate // 2, max_immediate)
            instr_list.append(f"ori ${i},$0,{immediate}")

    # 内存初始化
    addr = 0
    for i in range(reg_size):
        if i == 0 or 2 <= i <= 26:
            instr_list.append(f"sw ${i},{addr}($0)")
            addr += 4

    # 随机选择一个循环部分进入，当然也可以直接切入label0
    # choice = random.randint(0, 1)
    choice = 1
    if choice == 0:
        enter_pl = random.randint(0, num_of_loops // 10)
        instr_list.append(f"beq $0,$0,label{enter_pl}_end")
        instr_list.append(f"nop")

    # 开始生成循环
    for i in range(num_of_loops):
        loop_size = random.randint(loop_size_max // 2, loop_size_max)
        cycles = random.randint(1, 3)
        var = random.randint(2, 7)  # 循环变量
        generate_loop(loop_var=var, cycle_num=cycles, body_len=loop_size, label_num=i,
                      allowed_instr=instr_option, generate_prop=prop, instr_list=instr_list)

    instr_list.append(f"ori $26,32767")
    instr_list.append(f"ori $27,$0,32767")

    # 大范围跳转测试
    instr_list.append(f"common_block:")
    instr_list.append(f"beq $26,$27,end")
    instr_list.append(f"nop")
    instr_list.append(f"jr $31")
    instr_list.append(f"nop")

    # 程序结束
    instr_list.append(f"end:")
    instr_list.append(f"beq $27,$0,common_block")
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


if __name__ == "__main__":
    case_num = 10
    loop_num = 30
    max_loop_size = 80
    instr_opt = instr_in_body
    prob = instr_probs
    create_test(case_num, loop_num, max_loop_size, instr_opt, prob)
