namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void CLV(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.Status.V = false;

        outCpuCycle = 2;
    }
}