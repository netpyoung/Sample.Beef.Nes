namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void CLC(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.Status.C = false;

        outCpuCycle = 2;
    }
}