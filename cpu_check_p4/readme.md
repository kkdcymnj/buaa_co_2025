### Verilog CPU 对拍机使用说明

#### 写在前面

这个对拍机能够帮助您验证使用 **Verilog** 语言搭建的简易 CPU 是否能够正常工作。
目前这个机器支持生成包含 `add`，`sub`，`ori`，`lw`，`sw`，`beq`，`lui`，`jal` 和 `jr` 指令的数据用于评测。

#### 鸣谢

感谢 Toby 等学长贡献的魔改 MARS，这极大方便了我们的自测工作。

[下载链接](https://github.com/Toby-Shi-cloud/Mars-with-BUAA-CO-extension)

#### 构成

本对拍机主要由以下几部分构成：

1. 数据生成器，生成结果将以 `.asm` 文件格式存储到 `sample` 目录下（`generator.py`）
2. 利用 MARS 导出汇编程序对应的机器码，存储到 `machine_code` 目录下（`runmars.py`）
3. 将机器码注入进行评测，并比对输出，输出结果存储到 `results` 目录下（`runveri.py`）。
魔改版 MARS 输出的结果在 `output_true_{x}.txt`，Verilog 搭建的 CPU 输出结果在 `output_my_{x}.txt`。

#### 使用方法

本对拍机的使用方法如下：

1. 在 `app` 目录下放置 `Mars_CO_v0.6.1.jar`，这个包及其源代码可以在[此处](https://github.com/Toby-Shi-cloud/Mars-with-BUAA-CO-extension)获取。
2. 将需要进行验证的 Verilog 文件放置到 `test_script` 目录下。请保证顶层模块为 `mips.v`，`testbench` 的模块名
为 `test`。顶层模块涉及到的各个组件也请一并放在此目录下。此外，请在该目录下新增 `code.txt` 文件。
3. 测试中需要用到 `$readmemh` 操作。请注意在 `main.py` 修改评测机所在路径 `path`，以及 IFU 模块中读文件的路径。保险起见可以写全局路径。
4. 运行 `main.py`，生成数据并进行评测。运行 `main.py` 时：
- 选择是否需要重新生成数据
- 输入本次测试数据组数
- 为了更好地测试跳转类型指令，在数据中我们会插入多个循环块。需要指定每组数据中包含的循环块数、每个循环块中语句数的上限。
- 魔改后的 MARS 最多可以支持 4096 条指令，请合理设置测试参数。
5. 测试开始，测试输出文件保存路径见**构成**部分的**第 3 点**。如果命令行中输出了报错信息，请参考**常见问题**部分。

#### 常见问题

1. 提示“请下载 MARS 并指定正确路径”：请仔细查看 `app` 目录下是否已经包含 `Mars_CO_v0.6.1.jar`。
请注意这里我们使用的是魔改版 MARS，官方的 MARS 不能完成过长代码的编译等过程。
2. 提示“文件不存在”“未能找到...”：请仔细查看：测试数据（包括汇编代码、机器码）是否已经生成并在正确的目录下
（汇编代码应在 `samples` 目录下，机器码应在 `machine_code` 目录下）；魔改版 MARS 的 jar 包
是否放置在了 `app` 目录下；`code.txt` 是否放置在 `test_script` 目录下。
3. iVerilog 提示“Unable to find the root module”：请检查是否在 `test_script` 目录下放置了测试文件 `test.v`，且测试模块名称为 `test`。
4. vvp 提示“Unable to open input file”：请检查是否在 `test_script` 目录下放置了 `code.txt`。

#### 后续计划

1. 修改数据生成部分代码，以提高测试数据强度。
2. 后续进行修改以支持 Verilog 搭建的流水线 CPU 的评测。
