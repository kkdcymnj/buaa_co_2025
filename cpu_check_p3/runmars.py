import subprocess
import os
import tempfile
import random
import generator


def generate_and_assemble_mars(test_cases_dir="samples", output_dir="machine_code",
                               mars_jar="app\\Mars.jar", test_case_num=10):
    os.makedirs(output_dir, exist_ok=True)

    if not os.path.exists(mars_jar):
        print(f"错误: 找不到 {mars_jar}，请下载 MARS 并指定正确路径")
        return

    for i in range(test_case_num):
        filename = f"test_case_{i + 1}"
        input_file = os.path.join(test_cases_dir, f"{filename}.asm")
        output_file = os.path.join(output_dir, f"machine_{filename}.txt")

        if not input_file:
            print(f"× 输入文件 {filename}.asm 不存在")
            continue
        if not output_file:
            print(f"× 输出目标 machine_{filename}.txt 不存在")
            continue

        cmd = f"java -jar {mars_jar} a nc dump .text HexText {output_file} {input_file}"

        try:
            print(f"正在汇编: {filename}")
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

            if result.returncode == 0:
                print(f"✓ 成功生成: {output_file}")
            else:
                print(f"✗ 汇编失败: {filename}")
                print(f"错误信息: {result.stderr}")

        except Exception as e:
            print(f"✗ 错误: {filename} - {e}")


def create_and_assemble_tests(num_tests=10, instr_num=100, mars_jar="app\\Mars.jar"):
    # 生成测试用例
    test_cases = generator.generate_multiple_cases(num_tests, instr_num)
    os.makedirs("samples", exist_ok=True)

    i = 0
    for test_case in test_cases:
        with open(f'samples/test_case_{i + 1}.asm', 'w', encoding='utf-8') as f:
            f.write(test_case)
        print(f"测试用例 {i + 1} 已保存")
        i = i + 1

    generate_and_assemble_mars(mars_jar=mars_jar, test_case_num=num_tests)


if __name__ == "__main__":
    create_and_assemble_tests(10)
