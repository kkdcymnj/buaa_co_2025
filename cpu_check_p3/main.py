import runcirc
import runmars

logisim_jar = "app\\logisim-generic-2.7.1.jar"
mars_jar = "app\\Mars.jar"
file_a_in = f"test_script\\cpuA.circ"
file_b_in = f"test_script\\cpuB.circ"
testbench = f"test_script\\testbench.circ"

if __name__ == "__main__":
    option = input("是否需要重新生成测试数据？[Y/N]")
    if option == "Y" or option == "y":
        test_case_num = int(input("输入测试数据组数："))
        instr_num = int(input("输入每组数据指令条数："))
        runmars.create_and_assemble_tests(test_case_num, instr_num, mars_jar)
        runcirc.run_case(file_a_in, file_b_in, testbench, logisim_jar, test_case_num)
    elif option == "N" or option == "n":
        test_case_num = int(input("输入测试数据组数："))
        runcirc.run_case(file_a_in, file_b_in, testbench, logisim_jar, test_case_num)
    else:
        print("× 只能输入Y/N字符，请重新运行程序！")