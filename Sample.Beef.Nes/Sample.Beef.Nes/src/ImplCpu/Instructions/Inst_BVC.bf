

namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void BVC(Cpu cpu, out int outCpuCycle)
    {
        i8 offset = (i8)cpu.FetchByte();
        if (!cpu.Register.Status.V)
        {
            u16 currPc = cpu.Register.PC;
            u16 nextPc = (u16)((int)currPc + offset);
            cpu.Register.PC = nextPc;

            bool isPageCrossed = (currPc & 0xFF00) != (nextPc & 0xFF00);
            if (isPageCrossed)
            {
                outCpuCycle = 4;
            }
            else
            {
                outCpuCycle = 3;
            }
        }
        else
        {
            outCpuCycle = 2;
        }
    }
}
