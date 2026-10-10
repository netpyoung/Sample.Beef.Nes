namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    private static void _LDY(Cpu cpu, u8 v)
    {
        cpu.Register.Y = v;
        cpu.Register.Status.SetZfromValue(v);
        cpu.Register.Status.SetNfromValue(v);
    }

    public static void LDY_IMMEDIATE(Cpu cpu, out int outCycle)
    {
        u8 v = cpu.FetchByte();
        _LDY(cpu, v);

        outCycle = 2;
    }

    public static void LDY_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        _LDY(cpu, v);

        outCycle = 3;
    }

    public static void LDY_ZERO_PAGE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        u8 v = cpu.ReadByte(addr);
        _LDY(cpu, v);

        outCycle = 4;
    }

    public static void LDY_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        _LDY(cpu, v);

        outCycle = 4;
    }

    public static void LDY_ABSOLUTE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_X(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _LDY(cpu, v);

        outCycle = 4;
        if (isPageCrossed)
        {
            outCycle += 1;
        }
    }
}