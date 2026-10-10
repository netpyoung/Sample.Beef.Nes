namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void TXS(Cpu cpu, out int outCycle)
    {
        cpu.Register.SP = cpu.Register.X;

        outCycle = 2;
    }
}
