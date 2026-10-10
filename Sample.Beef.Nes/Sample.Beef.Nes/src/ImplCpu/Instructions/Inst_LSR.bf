
namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    private static u8 _LSR(Cpu cpu, u8 v)
    {
        cpu.Register.Status.C = v.IsFlagOn(E_STATUS_FLAG.FLAG_C);
        u8 result = (u8)(v >> 1);
        cpu.Register.Status.SetZfromValue(result);
        cpu.Register.Status.SetNfromValue(result);
        return result;
    }

    public static void LSR_ACCUMULATOR(Cpu cpu, out int outCycle)
    {
        cpu.Register.A = _LSR(cpu, cpu.Register.A);

        outCycle = 2;
    }

    public static void LSR_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        u8 result = _LSR(cpu, v);
        cpu.WriteByte(addr, result);

        outCycle = 5;
    }

    public static void LSR_ZERO_PAGE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage_X(cpu);
        u8 v = cpu.ReadByte(addr);
        u8 result = _LSR(cpu, v);
        cpu.WriteByte(addr, result);

        outCycle = 6;
    }

    public static void LSR_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        u8 result = _LSR(cpu, v);
        cpu.WriteByte(addr, result);

        outCycle = 6;
    }

    public static void LSR_ABSOLUTE_X(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute_X(cpu, let isPageCrossed);
        u8 v = cpu.ReadByte(addr);
        u8 result = _LSR(cpu, v);
        cpu.WriteByte(addr, result);

        outCycle = 7;
    }
}
