from fontTools.misc.cython import returns

import runveri
import runmars

instr_opt = ["add", "sub", "lw", "ori", "sw", "nop", "lui"]
prob = [0.2, 0.1, 0.2, 0.15, 0.2, 0.05, 0.1]
path = "D:\\CO\\homework\\p4_off\\cpu_check_p4"
mars_jar = f"{path}\\app\\Mars_CO_v0.6.1.jar"
tb_name = "test"

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

