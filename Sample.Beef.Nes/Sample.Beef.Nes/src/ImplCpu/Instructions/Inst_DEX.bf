namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void DEX(Cpu cpu, out int outCycle)
    {
        cpu.Register.X--;
        cpu.Register.Status.SetZfromValue(cpu.Register.X);
        cpu.Register.Status.SetNfromValue(cpu.Register.X);

        outCycle = 2;
    }
}
