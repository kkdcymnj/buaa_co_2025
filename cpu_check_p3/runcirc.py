# 这是一个对拍器

import re
import subprocess
from subprocess import PIPE, STDOUT
# from generator import create_test, generate_test_case
import os
import time
from sys import stdin, stderr

from jupyter_core.version import pattern

fail_list = []


def data_injection(file_a, file_b, n=10):
    if not os.path.exists(file_a):
        print(f"文件 {file_a} 不存在")
        return False

    if not os.path.exists(file_b):
        print(f"文件 {file_b} 不存在")
        return False

    machine_code_file = f"machine_code\\machine_test_case_{n + 1}.txt"
    if not os.path.exists(machine_code_file):
        print(f"文件 {machine_code_file} 不存在")
        return False

    with open(machine_code_file, 'r') as f:
        new_content = f.read()

    with open(file_a, 'r') as f:
        circ_a = f.read()

    with open(file_b, 'r') as f:
        circ_b = f.read()

    ptn = (r'(<comp lib="\d+" loc="\(\d+,\d+\)" name="ROM">'
           r'\s*<a name="addrWidth" val="\d+"/>'
           r'\s*<a name="dataWidth" val="\d+"/>'
           r'\s*<a name="contents">)[\s\S]*?(</a>)')

    match = re.search(ptn, circ_a)
    # print("√ 在电路 A 中找到了要替换的代码")
    replacement = match.group(1) + "addr/data: 12 32\n" + new_content + "\n" + match.group(2)
    # print(replacement)
    new_circ_a = re.sub(ptn, replacement, circ_a)

    match = re.search(ptn, circ_b)
    # print("√ 在电路 B 中找到了要替换的代码")
    replacement = match.group(1) + "addr/data: 12 32\n" + new_content + "\n" + match.group(2)
    new_circ_b = re.sub(ptn, replacement, circ_b)

    with open(file_a, 'w') as f:
        f.write(new_circ_a)

    with open(file_b, 'w') as f:
        f.write(new_circ_b)

    print(f"√ 测试 {n + 1} 的数据已经载入")
    return True


def execute(file_a, file_b, testbench, machine, n):
    file_a_output = f"results\\output_{n + 1}A.txt"
    file_b_output = f"results\\output_{n + 1}B.txt"

    if not os.path.exists(machine):
        print(f"未能找到 {machine} ，测试不能进行")
        return

    cmd_load_a = f"java -jar {machine} {testbench} -load {file_a}"
    result = subprocess.run(cmd_load_a, shell=True, stdout=PIPE, stderr=STDOUT)
    if result.stderr:
        print(f"× 将电路{file_a}导入时出错：{result.stderr}")
        return
    cmd_a = f"java -jar {machine} {testbench} -tty table"
    print("正在运行A电路")
    result_a = subprocess.run(cmd_a, shell=True, capture_output=True, text=True)
    if result_a.stderr:
        print(f"{file_a}报错：")
        print(result_a.stderr)
        return
    else:
        with open(file_a_output, 'w') as f:
            f.write(result_a.stdout)

    cmd_load_b = f"java -jar {machine} {testbench} -load {file_b}"
    result = subprocess.run(cmd_load_b, shell=True, stdout=PIPE, stderr=STDOUT)
    if result.stderr:
        print(f"× 将电路{file_b}导入时出错：{result.stderr}")
        return
    cmd_b = f"java -jar {machine} {testbench} -tty table"
    print("正在运行B电路")
    result_b = subprocess.run(cmd_b, shell=True, capture_output=True, text=True)
    if result_b.stderr:
        print(f"{file_a}报错：")
        print(result_b.stderr)
        return
    else:
        with open(file_b_output, 'w') as f:
            f.write(result_b.stdout)

    print(f"测试 {n + 1} 完成:")
    print(f"  电路A输出保存到: {file_a_output}")
    print(f"  电路B输出保存到: {file_b_output}")

    if not compare_file(file_a_output, file_b_output):
        fail_list.append(n + 1)


def compare_file(file_a, file_b):
    with open(file_a, 'r') as f:
        content_a = f.read()
    with open(file_b, 'r') as f:
        content_b = f.read()
    if content_a != content_b:
        print("  [× 两个电路输出不同]")
        print("--------------------")
        return False
    else:
        print("  [√ 两个电路输出相同]")
        print("--------------------")
        return True


def run_case(file_a, file_b, testbench, machine, n=10):
    fail_list.clear()
    for i in range(n):
        res = data_injection(file_a, file_b, i)
        if res:
            execute(file_a, file_b, testbench, machine, i)
    print(f"√ 全部测试已经完成！本次对拍了 {n} 组数据，"
          f"其中结果相同 {n - len(fail_list)} 组，不同 {len(fail_list)} 组")
    if fail_list:
        print(f"  输出不同的的数据组编号为：{fail_list}")
