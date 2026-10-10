
namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void DEC_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr) - 1;

        cpu.WriteByte(addr, v);
        cpu.Register.Status.SetZfromValue(v);
        cpu.Register.Status.SetNfromValue(v);

        outCycle = 5;
    }

    public static void DEC_ZERO_PAGE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        u8 v = cpu.ReadByte(addr) - 1;

        cpu.WriteByte(addr, v);
        cpu.Register.Status.SetZfromValue(v);
        cpu.Register.Status.SetNfromValue(v);

        outCycle = 6;
    }

    public static void DEC_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr) - 1;

        cpu.WriteByte(addr, v);
        cpu.Register.Status.SetZfromValue(v);
        cpu.Register.Status.SetNfromValue(v);

        outCycle = 6;
    }

    public static void DEC_ABSOLUTE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_X(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr) - 1;

        cpu.WriteByte(addr, v);
        cpu.Register.Status.SetZfromValue(v);
        cpu.Register.Status.SetNfromValue(v);

        outCycle = 7;
    }
}
