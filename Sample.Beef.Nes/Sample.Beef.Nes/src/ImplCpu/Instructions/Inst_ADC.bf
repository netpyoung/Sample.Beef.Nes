namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    private static void _ADC(Cpu cpu, u8 val)
    {
        u16 sum = (u16)cpu.Register.A + (u16)val;
        if (cpu.Register.Status.C)
        {
            sum++;
        }

        cpu.Register.Status.C = sum > 0xFF;

        u8 v = (u8)sum;
        u8 a = cpu.Register.A;
        u8 sameSign = ~(a ^ val);
        u8 diffSign = a ^ v;
        bool isOverflow = (sameSign & diffSign & 0x80) != 0;
        cpu.Register.Status.V = isOverflow;

        cpu.Register.A = v;
        cpu.Register.Status.SetZfromValue(v);
        cpu.Register.Status.SetNfromValue(v);
    }

    public static void ADC_IMMEDIATE(Cpu cpu, out int outCycle)
    {
        u8 v = cpu.FetchByte();
        _ADC(cpu, v);

        outCycle = 2;
    }

    public static void ADC_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        _ADC(cpu, v);

        outCycle = 3;
    }

    public static void ADC_ZERO_PAGE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        u8 v = cpu.ReadByte(addr);
        _ADC(cpu, v);

        outCycle = 4;
    }

    public static void ADC_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        _ADC(cpu, v);

        outCycle = 4;
    }

    public static void ADC_ABSOLUTE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_X(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _ADC(cpu, v);

        outCycle = 4;
        if (isPageCrossed)
        {
            outCycle += 1;
        }
    }

    public static void ADC_ABSOLUTE_Y(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_Y(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _ADC(cpu, v);

        outCycle = 4;
        if (isPageCrossed)
        {
            outCycle += 1;
        }
    }

    public static void ADC_INDIRECT_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Indirect_X(cpu);
        u8 v = cpu.ReadByte(addr);
        _ADC(cpu, v);

        outCycle = 6;
    }

    public static void ADC_INDIRECT_Y(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Indirect_Y(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        _ADC(cpu, v);

        outCycle = 5;
        if (isPageCrossed)
        {
            outCycle += 1;
        }
    }
}
