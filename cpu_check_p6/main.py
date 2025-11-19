from fontTools.misc.cython import returns

import runveri
import runmars

instr_opt = ["add","sub","or","and","slt","sltu",
             "addi","andi","ori","lui",
             "lw","lh","lb","sw","sh","sb",
             "mult","multu","div","divu",
             "mthi","mtlo",
             "nop"]

prob = [
    # 算术逻辑指令 - 高频
    0.08,  # add  - 最常用
    0.06,  # sub  - 常用
    0.05,  # or   - 较常用
    0.05,  # and  - 较常用
    0.02,  # slt  - 比较指令，较少用
    0.02,  # sltu - 无符号比较，较少用

    # 立即数指令 - 中高频
    0.08,  # addi - 很常用
    0.04,  # andi - 较常用
    0.04,  # ori  - 较常用
    0.05,  # lui  - 加载高位，较常用

    # 访存指令 - 中频
    0.10,  # lw   - 最常用的加载指令
    0.03,  # lh   - 半字加载，较少用
    0.03,  # lb   - 字节加载，较少用
    0.08,  # sw   - 最常用的存储指令
    0.02,  # sh   - 半字存储，较少用
    0.02,  # sb   - 字节存储，较少用

    # 乘除指令 - 低频
    0.03,  # mult  - 乘法，较少用
    0.02,  # multu - 无符号乘法，较少用
    0.02,  # div   - 除法，较少用
    0.02,  # divu  - 无符号除法，较少用

    # 特殊寄存器指令 - 很低频
    0.01,  # mthi - 很少用
    0.01,  # mtlo - 很少用

    # 空指令
    0.03  # nop  - 用于流水线停顿等
]

path = "D:\\CO\\homework\\p6_off\\cpu_check_p6"
mars_jar = f"{path}\\app\\Mars_CO_v0.6.1.jar"
tb_name = "mips_txt"

if __name__ == "__main__":
    option = input("是否需要重新生成测试数据？[Y/N]")
    if option == "Y" or option == "y":
        test_case_num = int(input("输入测试数据组数："))
        loop_num = int(input("输入构建每组数据的循环块数："))
        max_loop_size = int(input("输入每个循环体语句数上限："))
        runmars.create_and_assemble_tests(test_case_num, loop_num, max_loop_size, instr_opt, prob, mars_jar)
        runveri.run_case(path, tb_name, mars_jar, test_case_num)
    elif option == "N" or option == "n":
        test_case_num = int(input("输入测试数据组数："))
        runveri.run_case(path, tb_name, mars_jar, test_case_num)
    else:
        print("× 只能输入Y/N字符，请重新运行程序！")

