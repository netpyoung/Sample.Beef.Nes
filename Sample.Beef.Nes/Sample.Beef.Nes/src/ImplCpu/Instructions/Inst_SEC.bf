namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void SEC(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.Status.C = true;

        outCpuCycle = 2;
    }
}
