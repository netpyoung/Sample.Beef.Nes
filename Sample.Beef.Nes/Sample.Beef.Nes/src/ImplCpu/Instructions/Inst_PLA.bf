namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void PLA(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.A = cpu.Stack.PopByte();
        cpu.Register.Status.SetZfromValue(cpu.Register.A);
        cpu.Register.Status.SetNfromValue(cpu.Register.A);

        outCpuCycle = 4;
    }
}