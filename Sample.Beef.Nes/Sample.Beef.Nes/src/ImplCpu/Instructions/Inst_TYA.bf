namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void TYA(Cpu cpu, out int outCycle)
    {
        cpu.Register.A = cpu.Register.Y;
        cpu.Register.Status.SetZfromValue(cpu.Register.A);
        cpu.Register.Status.SetNfromValue(cpu.Register.A);

        outCycle = 2;
    }
}
