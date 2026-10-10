
namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void RTI(Cpu cpu, out int outCpuCycle)
    {
        u8 status = cpu.Stack.PopByte();
        status &= ~(u8)E_STATUS_FLAG.FLAG_B;
        status |= (u8)E_STATUS_FLAG.FLAG_U;

        cpu.Register.Status.Reset(status);
        cpu.Register.PC = cpu.Stack.PopWord();

        outCpuCycle = 6;
    }
}
