

namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    private static void _CMP(Cpu cpu, u8 registerValue, u8 operand)
    {
        u8 result = registerValue - operand;

        cpu.Register.Status.C = registerValue >= operand;
        cpu.Register.Status.SetZfromValue(result);
        cpu.Register.Status.SetNfromValue(result);
    }

    public static void CMP_IMMEDIATE(Cpu cpu, out int outCpuCycle)
    {
        u8 v = cpu.FetchByte();
        _CMP(cpu, cpu.Register.A, v);

        outCpuCycle = 2;
    }

    public static void CMP_ZERO_PAGE(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.A, v);

        outCpuCycle = 3;
    }

    public static void CMP_ZERO_PAGE_X(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.A, v);

        outCpuCycle = 4;
    }

    public static void CMP_ABSOLUTE(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.A, v);

        outCpuCycle = 4;
    }

    public static void CMP_ABSOLUTE_X(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Absolute_X(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.A, v);

        outCpuCycle = 4;
        if (isPageCrossed)
        {
            outCpuCycle += 1;
        }
    }

    public static void CMP_ABSOLUTE_Y(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Absolute_Y(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.A, v);

        outCpuCycle = 4;
        if (isPageCrossed)
        {
            outCpuCycle += 1;
        }
    }

    public static void CMP_INDIRECT_X(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Indirect_X(cpu);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.A, v);

        outCpuCycle = 6;
    }

    public static void CMP_INDIRECT_Y(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Indirect_Y(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.A, v);

        outCpuCycle = 5;
        if (isPageCrossed)
        {
            outCpuCycle += 1;
        }
    }
}
