

namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void STY_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        cpu.WriteByte(addr, cpu.Register.Y);

        outCycle = 3;
    }

    public static void STY_ZERO_PAGE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        cpu.WriteByte(addr, cpu.Register.Y);

        outCycle = 4;
    }

    public static void STY_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        cpu.WriteByte(addr, cpu.Register.Y);

        outCycle = 4;
    }
}
