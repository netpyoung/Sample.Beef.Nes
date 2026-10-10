
namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void JSR(Cpu cpu, out int outCpuCycle)
    {
        u16 addr = Addressing.Absolute(cpu);
        cpu.Stack.PushWord(cpu.Register.PC - 1);
        cpu.Register.PC = addr;

        outCpuCycle = 6;
    }
}
