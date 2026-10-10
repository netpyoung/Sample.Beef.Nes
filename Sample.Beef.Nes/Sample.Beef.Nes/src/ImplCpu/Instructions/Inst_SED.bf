namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void SED(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.Status.D = true;

        outCpuCycle = 2;
    }
}
