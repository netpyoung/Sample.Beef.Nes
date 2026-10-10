

namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    private static void _SBC(Cpu cpu, u8 val)
    {
        _ADC(cpu, ~val);
    }

    public static void SBC_IMMEDIATE(Cpu cpu, out int outCycle)
    {
        u8 v = cpu.FetchByte();
        _SBC(cpu, v);

        outCycle = 2;
    }

    public static void SBC_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        _SBC(cpu, v);

        outCycle = 3;
    }

    public static void SBC_ZERO_PAGE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        u8 v = cpu.ReadByte(addr);
        _SBC(cpu, v);

        outCycle = 4;
    }

    public static void SBC_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        _SBC(cpu, v);

        outCycle = 4;
    }

    public static void SBC_ABSOLUTE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_X(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _SBC(cpu, v);

        outCycle = 4;
        if (isPageCrossed)
        {
            outCycle += 1;
        }
    }

    public static void SBC_ABSOLUTE_Y(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_Y(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _SBC(cpu, v);

        outCycle = 4;
        if (isPageCrossed)
        {
            outCycle += 1;
        }
    }

    public static void SBC_INDIRECT_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Indirect_X(cpu);
        u8 v = cpu.ReadByte(addr);
        _SBC(cpu, v);

        outCycle = 6;
    }

    public static void SBC_INDIRECT_Y(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Indirect_Y(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _SBC(cpu, v);

        outCycle = 5;
        if (isPageCrossed)
        {
            outCycle += 1;
        }
    }
}