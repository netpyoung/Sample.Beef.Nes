

namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void STA_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        cpu.WriteByte(addr, cpu.Register.A);

        outCycle = 3;
    }

    public static void STA_ZERO_PAGE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        cpu.WriteByte(addr, cpu.Register.A);

        outCycle = 4;
    }

    public static void STA_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        cpu.WriteByte(addr, cpu.Register.A);

        outCycle = 4;
    }

    public static void STA_ABSOLUTE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_X(cpu, let isPageCrossed);
        cpu.WriteByte(addr, cpu.Register.A);

        outCycle = 5;
    }

    public static void STA_ABSOLUTE_Y(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_Y(cpu, let isPageCrossed);
        cpu.WriteByte(addr, cpu.Register.A);

        outCycle = 5;
    }

    public static void STA_INDIRECT_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Indirect_X(cpu);
        cpu.WriteByte(addr, cpu.Register.A);

        outCycle = 6;
    }

    public static void STA_INDIRECT_Y(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Indirect_Y(cpu, let isPageCrossed);
        cpu.WriteByte(addr, cpu.Register.A);

        outCycle = 6;
    }
}
