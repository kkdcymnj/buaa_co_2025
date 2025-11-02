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

supported_instr = ["add", "sub", "lw", "sw", "beq", "nop", "lui", "jal", "jr"]
generate_props = [0.15, 0.15, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]

label_props = [0.1, 0.9]


def generate_test_case(n=50):
    operation_list = [".data", "array:.space 4096", ".text"]
    current_pc = 0x3000
    start_pc = current_pc

    label_sum = int(0.08 * n)
    label_pos = random.sample(range(n - 3), label_sum)
    label_pc_list = []
    label_count = 0
    label_id = 0

    register_list = [0] * 32

    # 初始化寄存器中数值
    for i in range(reg_size):
        if i != 1:
            while True:
                immediate = random.randint(0, max_immediate)
                if immediate % 4==0:
                    break
            operation_list.append(f"ori ${i},$0,{immediate}")
            register_list[i] = immediate
            current_pc += 4

    #计算各个label对应的PC
    for pos in label_pos:
        label_pc_list.append(current_pc + 4 * pos)

    for i in range(n):
        cur_instr = random.choices(supported_instr, generate_props)[0]

        if i in label_pos:
            operation_list.append(f"label{label_count}:")
            label_count += 1

        # print("Generating instruction {}".format(cur_instr))

        while True:
            rs = random.randint(0, reg_size - 1)
            base = rs
            rt = random.randint(0, reg_size - 1)
            rd = random.randint(0, reg_size - 1)
            if rs != 1 and rt != 1 and rd != 1:
                break

        while True:
            base = random.randint(0, reg_size - 1)
            if base != rt:
                break

        immediate = 0
        off = 0

        if cur_instr == "beq" or cur_instr == "jal":
            choice = random.randint(0, 2)

            if choice == 0:
                if label_count >= 1:
                    label_id = random.randint(0, label_count - 1)
                else:
                    label_id = 0
            if choice == 1:
                if label_count == label_sum:
                    label_id = label_sum - 1
                else:
                    label_id = label_count
            if choice == 2:
                if label_count < label_sum - 1:
                    label_id = random.randint(label_count + 1, label_sum - 1)
                else:
                    label_id = label_sum - 1

        elif cur_instr == "lw" or cur_instr == "sw":
            while True:
                off = random.randint(0, 4096)
                if off % 4 == 0:
                    break
        else:
            immediate = random.randint(0, max_immediate)

        match cur_instr:
            case "add":
                operation_list.append(f"{cur_instr} ${rd},${rs},${rt}")
            case "sub":
                operation_list.append(f"{cur_instr} ${rd},${rs},${rt}")
            case "lw":
                operation_list.append(f"{cur_instr} ${rt},{off}($0)")
            case "sw":
                operation_list.append(f"{cur_instr} ${rt},{off}($0)")
            case "beq":
                operation_list.append(f"{cur_instr} ${rs},${rt},label{label_id}")
            case "nop":
                operation_list.append(f"{cur_instr}")
            case "lui":
                operation_list.append(f"{cur_instr} ${rt},{immediate}")
            case "jal":
                operation_list.append(f"{cur_instr} label{label_id}")
            case "jr":
                operation_list.append(f"{cur_instr} ${31}")

        current_pc += 4

    return '\n'.join(operation_list)


def generate_multiple_cases(num_of_cases=10, instr_num=100):
    test_case_list = []
    for i in range(num_of_cases):
        # n = random.randint(1400, 1500)
        #instr_num = 100
        test_case_list.append(generate_test_case(instr_num))
    return test_case_list


def create_test(n=10, instr_num=100):
    test_cases = generate_multiple_cases(n)
    os.makedirs("samples", exist_ok=True)

    # 样例保存到文件
    for i, test_case in enumerate(test_cases, 1):
        with open(f'samples\\test_case_{i}.txt', 'w', encoding='utf-8') as f:
            f.write(test_case)
        print(f"样例 {i} 已经保存到文件 test_case_{i}.txt")


if __name__ == "__main__":
    create_test(10)
