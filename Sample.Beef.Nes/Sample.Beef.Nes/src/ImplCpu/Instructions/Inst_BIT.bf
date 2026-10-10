

namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    private static void _BIT(Cpu cpu, u8 v)
    {
        cpu.Register.Status.SetZfromValue(cpu.Register.A & v);
        cpu.Register.Status.SetNfromValue(v);
        cpu.Register.Status.V = v.IsFlagOn(E_STATUS_FLAG.FLAG_V);
    }


    public static void BIT_ZERO_PAGE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        _BIT(cpu, v);

        outCycle = 3;
    }

    public static void BIT_ABSOLUTE(Cpu cpu, out int outCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        _BIT(cpu, v);

        outCycle = 4;
    }
}
