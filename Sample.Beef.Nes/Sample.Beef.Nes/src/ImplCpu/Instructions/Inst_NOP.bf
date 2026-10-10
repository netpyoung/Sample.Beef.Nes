namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void NOP(Cpu cpu, out int outCycle)
    {
        outCycle = 2;
    }
}
