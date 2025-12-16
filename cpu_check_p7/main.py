import runveri
import runmars

instr_opt = ["add","sub","or","and","slt","sltu",
             "addi","andi","ori","lui",
             "lw","lh","lb","sw","sh","sb",
             "mult","multu","div","divu",
             "mthi","mtlo",
             "nop",
             "syscall"]

prob = [
    # 算术逻辑指令 - 只保留可能溢出的
    0.25,  # add  (可能溢出)
    0.10,  # sub  (可能溢出)
    0.00,  # or   (无对应异常)
    0.00,  # and  (无对应异常)
    0.00,  # slt  (无对应异常)
    0.00,  # sltu (无对应异常)

    # 立即数指令
    0.00,  # addi (可能溢出)
    0.00,  # andi (无对应异常)
    0.00,  # ori  (无对应异常)
    0.00,  # lui  (保留，虽无直接异常但可能产生异常地址)

    # 访存指令
    0.16,  # lw   (可能地址异常)
    0.05,  # lh   (可能地址异常)
    0.05,  # lb   (可能访问Timer异常)
    0.16,  # sw   (可能地址异常)
    0.05,  # sh   (可能地址异常)
    0.05,  # sb   (可能访问Timer异常)

    # 乘除指令 - 保留，可能除零
    0.05,  # mult
    0.00,  # multu
    0.05,  # div   (可能除零)
    0.00,  # divu  (可能除零)

    # 特殊寄存器指令 - 保留，可能触发特殊异常
    0.01,  # mthi
    0.01,  # mtlo

    # 空指令 - 少量保留用于控制流程
    0.00,  # nop

    0.01   # syscall
]

path = "D:\\CO\\homework\\p7_off\\cpu_check_p7"
mars_jar = f"{path}\\app\\mars.jar"
tb_name = "mips_txt"

if __name__ == "__main__":

    runmars.assemble_exception_handler()

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

