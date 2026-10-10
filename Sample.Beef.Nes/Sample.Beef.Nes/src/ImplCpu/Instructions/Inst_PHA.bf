namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void PHA(Cpu cpu, out int outCpuCycle)
    {
        cpu.Stack.PushByte(cpu.Register.A);

        outCpuCycle = 3;
    }
}