import cocotb
from cocotb.triggers import Timer
import random

ITERATIONS = 1000
U32_MAX = 0xffffffff

def signed(n):
    if n & 0x80000000:
        return n - 0x100000000
    else:
        return n

def add(a, b):
    return (a + b) & U32_MAX

def slt(a, b):
    return int(signed(a) < signed(b))

def sltu(a, b):
    return int(a < b)

def bitand(a, b):
    return a & b

def bitor(a, b):
    return a | b

def bitxor(a, b):
    return a ^ b

def sll(a, b):
    return (a << b) & U32_MAX

def slr(a, b):
    return (a >> b) & U32_MAX

def sub(a, b):
    return (a - b) & U32_MAX

def sar(a, b):
    result = signed(a) >> b
    return (result + 0x100000000) & U32_MAX

async def generic_alu_test(op, op_id, op_name, a, b, dut):
    out = op(a, b)
    zf = int(out == 0)
    dut.op.value = op_id
    dut.a.value = a
    dut.b.value = b
    await Timer(10, units="ns")
    assert dut.out == out, f"{op_name} failed: a={a}, b={b}, expected_out={out}, out={dut.out.value}"
    assert dut.zero.value == zf, f"{op_name} failed: a={a}, b={b}, expected_zf={zf}, zf={dut.zf.value}"

@cocotb.test()
async def alu_test_add(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, U32_MAX)
        b = random.randint(0, U32_MAX)
        await generic_alu_test(add, 0, "Add", a, b, dut)

@cocotb.test()
async def alu_test_slt(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 0xffffffff)
        await generic_alu_test(slt, 1, "Slt", a, b, dut)

@cocotb.test()
async def alu_test_sltu(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 0xffffffff)
        await generic_alu_test(sltu, 2, "Sltu", a, b, dut)

@cocotb.test()
async def alu_test_and(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 0xffffffff)
        await generic_alu_test(bitand, 3, "BitAnd", a, b, dut)

@cocotb.test()
async def alu_test_or(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 0xffffffff)
        await generic_alu_test(bitor, 4, "BitOr", a, b, dut)

@cocotb.test()
async def alu_test_xor(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 0xffffffff)
        await generic_alu_test(bitxor, 5, "BitXor", a, b, dut)

@cocotb.test()
async def alu_test_sll(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 100)
        await generic_alu_test(sll, 6, "Sll", a, b, dut)

@cocotb.test()
async def alu_test_slr(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 100)
        await generic_alu_test(slr, 7, "slr", a, b, dut)

@cocotb.test()
async def alu_test_sub(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 0xffffffff)
        await generic_alu_test(sub, 8, "sub", a, b, dut)

@cocotb.test()
async def alu_test_sar(dut):
    for i in range(ITERATIONS):
        a = random.randint(0, 0xffffffff)
        b = random.randint(0, 100)
        await generic_alu_test(sar, 9, "sar", a, b, dut)
