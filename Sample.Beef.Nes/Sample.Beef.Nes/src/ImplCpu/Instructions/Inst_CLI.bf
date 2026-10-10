namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void CLI(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.Status.I = false;

        outCpuCycle = 2;
    }
}
