import random

reg_size = 32
mem_size = 4096
max_immediate = 2 ** 16 - 1
min_immediate = -2 ** 15


def add_command_RR(cur_instr, rs, rt, rd, instr_list):
    instr_list.append(f"{cur_instr} ${rd},${rs},${rt}")


def add_command_RI(cur_instr, rs, rt, instr_list):
    immediate = random.randint(max_immediate // 2, max_immediate)
    if cur_instr != "lui":
        instr_list.append(f"{cur_instr} ${rt},${rs},{immediate}")
    else:
        instr_list.append(f"lui ${rt},{immediate}")


def add_command_LD_ST(cur_instr, rt, instr_list, option=-1, invalid=-1):
    if option == -1:
        choice = random.choices([0,1,3],[0.4,0.5,0.1])
    else:
        choice = option

    if invalid == -1:
        invalid_addr_choice = random.randint(0, 1)
    else:
        invalid_addr_choice = invalid

    match choice:
        case 0:
            while True:
                address = random.randint(0, 16)
                if invalid_addr_choice:
                    if "w" in cur_instr:
                        if address % 4 != 0:
                            break
                    elif "h" in cur_instr:
                        if address % 2 != 0:
                            break
                    else:
                        break
                else:
                    if "w" in cur_instr:
                        if address % 4 == 0:
                            break
                    elif "h" in cur_instr:
                        if address % 2 == 0:
                            break
                    else:
                        break

            instr_list.append(f"{cur_instr} ${rt},{address}(${0})")
        case 1:
            region_choice = random.randint(0, 2)
            while True:
                if region_choice == 0:
                    address = random.randint(-100, -1)
                elif region_choice == 1:
                    address = random.randint(0x3000, 0x6FFF)
                else:
                    address = random.randint(0x7F24, 0x7FFF)

                if "w" in cur_instr:
                    if address % 4 == 0:
                        break
                elif "h" in cur_instr:
                    if address % 2 == 0:
                        break
                else:
                    break

            instr_list.append(f"{cur_instr} ${rt},{address}(${0})")
        case 2:
            region_choice = random.randint(0, 1)
            if cur_instr == "lw":
                while True:
                    if region_choice == 0:
                        address = random.randint(0x7f00, 0x7f0b)
                    else:
                        address = random.randint(0x7f10, 0x7f1b)

                    if address % 4 == 0:
                        break
            elif cur_instr == "sw":
                if region_choice == 0:
                    address = 0x7f08
                else:
                    address = 0x7f18
            else:
                while True:
                    if region_choice == 0:
                        address = random.randint(0x7f00, 0x7f0b)
                    else:
                        address = random.randint(0x7f10, 0x7f1b)

                    if cur_instr == "lh" or cur_instr == "sh":
                        if address % 2 == 0:
                            break
                    else:
                        break

            instr_list.append(f"{cur_instr} ${rt},{address}($0)")
        case 3:
            instr_list.append(f"lui $10,0x7fff")
            instr_list.append(f"ori $10,$10,0xffff")
            instr_list.append(f"{cur_instr} ${rt},4($10)")


def add_command_MDU(cur_instr, rs, rt, instr_list):
    immediate = random.randint(2, max_immediate // 4)
    instr_list.append(f"ori ${rt},${rt},{immediate}")
    instr_list.append(f"{cur_instr} ${rs} ${rt}")


def generate_single_command(allowed_instr, generate_prop, instr_list, loop_var, mult_mark):
    choice_range = [i for i in range(11, 15) if i != loop_var]
    rs = random.choice(choice_range)
    rt = random.choice(choice_range)
    rd = random.choice(choice_range)

    if mult_mark == 1:
        choice = random.randint(0, 1)
        if choice == 0:
            instr_list.append(f"mfhi ${rs}")
        else:
            instr_list.append(f"mflo ${rs}")
        return 0

    cur_instr = random.choices(allowed_instr, generate_prop)[0]
    # print(f"cur instr = {cur_instr}")

    match cur_instr:
        case "add" | "sub" | "or" | "and" | "slt" | "sltu":
            add_command_RR(cur_instr, rs, rt, rd, instr_list)
            return 0
        case "ori" | "addi" | "andi" | "lui":
            add_command_RI(cur_instr, rs, rt, instr_list)
            return 0
        case "lw" | "sw" | "lh" | "sh" | "lb" | "sb":
            add_command_LD_ST(cur_instr, rt, instr_list)
            return 0
        case "mult" | "multu" | "div" | "divu":
            add_command_MDU(cur_instr, rs, rt, instr_list)
            return 1
        case "mthi" | "mtlo":
            instr_list.append(f"{cur_instr} ${rs}")
            return 0
        case "nop":
            instr_list.append(f"nop")
            return 0
        case "syscall":
            instr_list.append(f"syscall")  # syscall异常
            return 0
    return None


def generate_error_command(instr_list):
    cur_instr = random.choice(["lw", "sw", "lh", "sh", "lb", "sb"])
    add_command_LD_ST(cur_instr, 19, instr_list, invalid=1)
