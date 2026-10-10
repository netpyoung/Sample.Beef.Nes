namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void CLD(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.Status.D = false;

        outCpuCycle = 2;
    }
}