
namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void PHP(Cpu cpu, out int outCpuCycle)
    {
        u8 x = cpu.Register.Status.Value;
        x |= (u8)E_STATUS_FLAG.FLAG_B;
        x |= (u8)E_STATUS_FLAG.FLAG_U;

        cpu.Stack.PushByte(x);

        outCpuCycle = 3;
    }
}