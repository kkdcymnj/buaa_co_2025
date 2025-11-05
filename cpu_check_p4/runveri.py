# 这是一个对拍器

import re
import subprocess
from subprocess import PIPE, STDOUT
# from generator import create_test, generate_test_case
import os
import time
from sys import stdin, stderr

from jupyter_core.version import pattern
from sympy import false
from torch.distributed import group

fail_list = []


def execute_asm(folder, file, n, machine=f"app\\Mars_CO_v0.6.1.jar"):
    file_output = f"{folder}\\results\\output_true_{n + 1}.txt"

    if not os.path.exists(machine):
        print(f"未能找到Mars包 {machine} ，标准答案不能生成")
        return
    if not os.path.exists(file):
        print(f"未能找到汇编文件 {file} ，标准答案不能生成")
        return

    cmd = f"java -jar {machine} {file} mc CompactLargeText coL1 ig"
    print(f"样例 {n + 1} 的标准答案正在生成中...")
    result = subprocess.run(cmd, shell=True, stdout=PIPE, stderr=STDOUT, text=True)

    if result.stderr:
        print(f"运行{file}报错：")
        print(result.stderr)
        return
    else:
        with open(file_output, 'w') as f:
            f.write(result.stdout)
        print(f"√ 样例 {n + 1} 的标准答案已经生成，保存到 {file_output} 中。")


def execute_verilog(folder, test_module_name, n):
    file_output = f"{folder}\\results\\output_my_{n + 1}.txt"
    test_case = f"{folder}\\machine_code\\machine_test_case_{n + 1}.txt"
    injection_file = f"{folder}\\test_script\\code.txt"
    if not os.path.exists(test_case) or not os.path.exists(injection_file):
        print(f"{test_case} 和 {injection_file} 至少有一者不存在！")
        return
    else:
        cmd = f"copy {test_case}  {injection_file}"
        subprocess.run(cmd,shell=True)
    os.chdir(f"{folder}\\test_script")
    cmd = f"iverilog -s {test_module_name} -o {test_module_name}.out *.v"
    subprocess.run(cmd,shell=True,text=True)
    print("√ 编译完成！")
    #os.chdir(folder)
    cmd = f"vvp {test_module_name}.out"
    result = subprocess.run(cmd, shell=True, stdout=PIPE, stderr=STDOUT, text=True)
    if result.stderr:
        print(f"运行{test_module_name}.out报错：")
        print(result.stderr)
        return
    else:
        with open(file_output, 'w') as f:
            f.write(result.stdout)
        print(f"√ 你的样例 {n + 1} 答案已经生成，保存到 {file_output} 中。")

def compare_file(file_a, file_b):
    if not os.path.exists(file_a):
        print(f"× 输出文件 {file_a} 不存在！")
        print(50 * "=")
        return False
    if not os.path.exists(file_b):
        print(f"× 输出文件 {file_b} 不存在！")
        print(50 * "=")
        return False

    with open(file_a, 'r') as f:
        content_a = [line.strip() for line in f if line.startswith('@')]
        content_a_converted = '\n'.join(content_a)

    with open(file_a, 'w') as f:
        f.write(content_a_converted)

    with open(file_b, 'r') as f:
        content_b = [line.strip() for line in f if line.startswith('@')]
        content_b_converted = '\n'.join(content_b)

    with open(file_b, 'w') as f:
        f.write(content_b_converted)

    if content_a_converted != content_b_converted:
        print("  [× 输出错误]")
        print(50 * "=")
        return False
    else:
        print("  [√ 输出正确]")
        print(50 * "=")
        return True


def run_case(path,tb_name,test_machine,group_num):
    for i in range(group_num):
        asm_file = f"{path}\\samples\\test_case_{i+1}.asm"
        execute_asm(path, asm_file, n=i, machine=test_machine)
        execute_verilog(path, tb_name, n=i)
        result = compare_file(f"{path}\\results\\output_true_{i + 1}.txt",
                     f"{path}\\results\\output_my_{i + 1}.txt")

        if not result:
            fail_list.append(i+1)
    print(f"√ 全部测试已经完成！本次对拍了 {group_num} 组数据，"
          f"其中结果相同 {group_num - len(fail_list)} 组，不同 {len(fail_list)} 组")
    if fail_list:
        print(f"测试不正确的数据组有：{fail_list}")