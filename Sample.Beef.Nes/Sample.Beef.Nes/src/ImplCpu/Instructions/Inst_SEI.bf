namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void SEI(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.Status.I = true;

        outCpuCycle = 2;
    }
}