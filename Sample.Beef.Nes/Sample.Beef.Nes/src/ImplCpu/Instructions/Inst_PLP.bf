
namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void PLP(Cpu cpu, out int outCpuCycle)
    {
        u8 status = cpu.Stack.PopByte();
        status &= ~(u8)E_STATUS_FLAG.FLAG_B;
        status |= (u8)E_STATUS_FLAG.FLAG_U;
        cpu.Register.Status.Reset(status);

        outCpuCycle = 4;
    }
}