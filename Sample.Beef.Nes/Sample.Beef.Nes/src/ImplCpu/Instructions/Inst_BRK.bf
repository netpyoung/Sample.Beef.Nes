
namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    readonly static u16 IRQ_VECTOR = (u16)0xFFFE;

    public static void BRK(Cpu cpu, out int outCpuCycle)
    {
        u16 returnAddr = cpu.Register.PC + 1;
        cpu.Stack.PushWord(returnAddr);

        u8 flag = (u8)cpu.Register.Status.Value;
        flag |= (u8)E_STATUS_FLAG.FLAG_B;
        flag |= (u8)E_STATUS_FLAG.FLAG_U;
        cpu.Stack.PushByte(flag);

        cpu.Register.Status.I = true;

        u16 lo = (u16)cpu.ReadByte(IRQ_VECTOR);
        u16 hi = (u16)cpu.ReadByte(IRQ_VECTOR + 1);
        cpu.Register.PC = (hi << 8) | lo;

        outCpuCycle = 7;
    }
}
