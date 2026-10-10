namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    private static void _LDX(Cpu cpu, u8 v)
    {
        cpu.Register.X = v;
        cpu.Register.Status.SetZfromValue(v);
        cpu.Register.Status.SetNfromValue(v);
    }

    public static void LDX_IMMEDIATE(Cpu cpu, out int outCycle)
    {
        u8 v = cpu.FetchByte();
        _LDX(cpu, v);

        outCycle = 2;
    }

    public static void LDX_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        _LDX(cpu, v);

        outCycle = 3;
    }

    public static void LDX_ZERO_PAGE_Y(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage_Y(cpu);
        u8 v = cpu.ReadByte(addr);
        _LDX(cpu, v);

        outCycle = 4;
    }

    public static void LDX_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        _LDX(cpu, v);

        outCycle = 4;
    }

    public static void LDX_ABSOLUTE_Y(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_Y(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _LDX(cpu, v);

        outCycle = 4;
        if (isPageCrossed)
        {
            outCycle += 1;
        }
    }
}