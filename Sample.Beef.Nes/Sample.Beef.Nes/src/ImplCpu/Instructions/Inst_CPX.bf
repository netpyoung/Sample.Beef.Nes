

namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void CPX_IMMEDIATE(Cpu cpu, out int outCpuCycle)
    {
        u8 v = cpu.FetchByte();
        _CMP(cpu, cpu.Register.X, v);

        outCpuCycle = 2;
    }

    public static void CPX_ZERO_PAGE(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.ZeroPage(cpu);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.X, v);

        outCpuCycle = 3;
    }

    public static void CPX_ABSOLUTE(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        u8 v = cpu.ReadByte(addr);
        _CMP(cpu, cpu.Register.X, v);

        outCpuCycle = 4;
    }
}
