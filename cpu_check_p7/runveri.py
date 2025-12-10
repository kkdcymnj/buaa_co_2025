import shutil
import subprocess
from subprocess import PIPE, STDOUT
import os

fail_list = []

def execute_asm(folder, file, n, machine=f"app\\Mars_CO_v0.6.1.jar"):
    file_output = f"{folder}\\results\\output_true_{n + 1}.txt"
    handler = f"{folder}\\exception_handler\\handler.asm"

    if not os.path.exists(machine):
        print(f"未能找到Mars包 {machine} ，标准答案不能生成")
        return
    if not os.path.exists(file):
        print(f"未能找到汇编文件 {file} ，标准答案不能生成")
        return

    cmd = f"java -jar {machine} {file} db mc CompactLargeText coL1"
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
        try:
            shutil.copy2(test_case, injection_file)
            # print(f"√ 成功复制 {test_case} 到 {injection_file}")
        except Exception as e:
            print(f"× 文件复制失败: {e}")
            return
    os.chdir(f"{folder}\\test_script")
    cmd = f"iverilog -s {test_module_name} -o {test_module_name}.out *.v"
    subprocess.run(cmd, shell=True, text=True)
    print("√ Verilog 文件编译完成！")
    # os.chdir(folder)
    cmd = f"vvp {test_module_name}.out"
    result = subprocess.run(cmd, shell=True, stdout=PIPE, stderr=STDOUT, text=True)
    if result.stderr:
        print(f"运行{test_module_name}.out报错：")
        print(result.stderr)
        return
    else:
        try:
            with open(file_output, 'w') as f:
                f.write(result.stdout)
        except Exception as e:
            print(f"× 结果写入失败：{e}")
            return
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
        content_a = []
        for line in f:
            if '@' in line:
                line_temp = line.strip()
                place = line_temp.find('@')
                result = line_temp[place:]
                content_a.append(result)
        content_a_converted = '\n'.join(content_a)

    with open(file_a, 'w') as f:
        f.write(content_a_converted)

    with open(file_b, 'r') as f:
        # content_b = [line.strip()[line.find('@'):] for line in f if '@' in line]
        content_b = []
        for line in f:
            if '@' in line:
                line_temp = line.strip()
                place = line_temp.find('@')
                result = line_temp[place:]
                content_b.append(result)
        content_b_converted = '\n'.join(content_b)

    with open(file_b, 'w') as f:
        f.write(content_b_converted)

    # 按照寄存器和内存操作分开比较输出
    with open(file_a, 'r') as f:
        lines_a = f.readlines()
        content_a_converted_reg = [line.strip() for line in lines_a if '$' in line]
        content_a_converted_mem = [line.strip() for line in lines_a if '*' in line]
        file_a_reg = os.path.splitext(file_a)[0] + "_reg.txt"
        file_a_reg = file_a_reg.replace("results","result_detailed")
        file_a_mem = os.path.splitext(file_a)[0] + "_mem.txt"
        file_a_mem = file_a_mem.replace("results", "result_detailed")
        with open(file_a_reg, 'w') as f1:
            f1.write('\n'.join(content_a_converted_reg))
        with open(file_a_mem, 'w') as f2:
            f2.write('\n'.join(content_a_converted_mem))


    with open(file_b, 'r') as f:
        lines_b = f.readlines()
        content_b_converted_reg = [line.strip() for line in lines_b if '$' in line]
        content_b_converted_mem = [line.strip() for line in lines_b if '*' in line]
        file_b_reg = os.path.splitext(file_b)[0] + "_reg.txt"
        file_b_reg = file_b_reg.replace("results", "result_detailed")
        file_b_mem = os.path.splitext(file_b)[0] + "_mem.txt"
        file_b_mem = file_b_mem.replace("results", "result_detailed")
        with open(file_b_reg, 'w') as f1:
            f1.write('\n'.join(content_b_converted_reg))
        with open(file_b_mem, 'w') as f2:
            f2.write('\n'.join(content_b_converted_mem))

    false_flag = False

    # 比较寄存器操作部分
    if content_a_converted_reg != content_b_converted_reg:
        print("  [× 输出错误，寄存器操作有不同]")

        # 找出并输出第一组不同的行
        min_len = len(content_a_converted_reg)
        if min_len == len(content_b_converted_reg):
            for i in range(min_len):
                if content_a_converted_reg[i] != content_b_converted_reg[i]:
                    print(f"    第 {i + 1} 行不同：")
                    print(f"    MARS 结果: {content_a_converted_reg[i]}")
                    print(f"    你的结果: {content_b_converted_reg[i]}")
                    break
        else:
            if min_len > len(content_b_converted_reg):
                print(f"    你的寄存器操作输出过少")
                print(f"    第 {len(content_b_converted_reg) + 1} 行中，你没有输出内容，"
                      f"但 MARS 输出了 {content_a_converted_reg[len(content_b_converted_reg)]}")
            else:
                print(f"    你的寄存器操作输出过多")
                print(f"    第 {min_len + 1} 行中，MARS 没有输出内容，"
                      f"但你输出了 {content_b_converted_reg[min_len]}")

        false_flag = True

    # 比较内存操作部分
    if content_a_converted_mem != content_b_converted_mem:
        print("  [× 输出错误，内存操作有不同]")

        # 找出并输出第一组不同的行
        min_len = len(content_a_converted_mem)
        if min_len == len(content_b_converted_mem):
            for i in range(min_len):
                if content_a_converted_mem[i] != content_b_converted_mem[i]:
                    print(f"    第 {i + 1} 行不同：")
                    print(f"    MARS 结果: {content_a_converted_mem[i]}")
                    print(f"    你的结果: {content_b_converted_mem[i]}")
                    break
        else:
            if min_len > len(content_b_converted_mem):
                print(f"    你的寄存器操作输出过少")
                print(f"    第 {len(content_b_converted_mem) + 1} 行中，你没有输出内容，"
                      f"但 MARS 输出了 {content_a_converted_mem[len(content_b_converted_mem)]}")
            else:
                print(f"    你的寄存器操作输出过多")
                print(f"    第 {min_len + 1} 行中，MARS 没有输出内容，"
                      f"但你输出了 {content_b_converted_mem[min_len]}")

        false_flag = True

    if not false_flag:
        print("  [√ 输出正确]")
        print(50 * "=")
        return True
    else:
        print(50 * "=")
        return False


def run_case(path, tb_name, test_machine, group_num):
    for i in range(group_num):
        asm_file = f"{path}\\samples\\test_case_{i + 1}.asm"
        execute_asm(path, asm_file, n=i, machine=test_machine)
        execute_verilog(path, tb_name, n=i)
        result = compare_file(f"{path}\\results\\output_true_{i + 1}.txt",
                              f"{path}\\results\\output_my_{i + 1}.txt")

        if not result:
            fail_list.append(i + 1)
    print(f"√ 全部测试已经完成！本次对拍了 {group_num} 组数据，"
          f"其中结果相同 {group_num - len(fail_list)} 组，不同 {len(fail_list)} 组")
    if fail_list:
        print(f"测试不正确的数据组有：{fail_list}")
