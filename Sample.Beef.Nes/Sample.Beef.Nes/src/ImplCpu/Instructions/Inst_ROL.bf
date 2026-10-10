namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    private static u8 _ROL(Cpu cpu, u8 v)
    {
        bool isCarryOn = cpu.Register.Status.C;

        cpu.Register.Status.C = v.IsFlagOn(E_STATUS_FLAG.FLAG_N);
        u8 result = (u8)(v << 1);
        if (isCarryOn)
        {
            result |= 0b0000'00001;
        }
        cpu.Register.Status.SetZfromValue(result);
        cpu.Register.Status.SetNfromValue(result);
        return result;
    }

    public static void ROL_ACCUMULATOR(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.A = _ROL(cpu, cpu.Register.A);

        outCpuCycle = 2;
    }

    public static void ROL_ZERO_PAGE(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        u8 result = _ROL(cpu, v);
        cpu.WriteByte(addr, result);

        outCpuCycle = 5;
    }

    public static void ROL_ZERO_PAGE_X(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        u8 v = cpu.ReadByte(addr);
        u8 result = _ROL(cpu, v);
        cpu.WriteByte(addr, result);

        outCpuCycle = 6;
    }

    public static void ROL_ABSOLUTE(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        u8 result = _ROL(cpu, v);
        cpu.WriteByte(addr, result);

        outCpuCycle = 6;
    }

    public static void ROL_ABSOLUTE_X(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Absolute_X(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        u8 result = _ROL(cpu, v);
        cpu.WriteByte(addr, result);

        outCpuCycle = 7;
    }
}
