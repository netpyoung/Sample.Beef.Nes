namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void DEY(Cpu cpu, out int outCycle)
    {
        cpu.Register.Y--;
        cpu.Register.Status.SetZfromValue(cpu.Register.Y);
        cpu.Register.Status.SetNfromValue(cpu.Register.Y);

        outCycle = 2;
    }
}
