

namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void RTS(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = cpu.Stack.PopWord();
        cpu.Register.PC = addr + 1;

        outCpuCycle = 6;
    }
}
