using System;
namespace Sample.Beef.Nes.ImplCpu;

class Cpu
{
    public enum CpuError
    {
        case UnknownOpcode;
    }

    readonly static u16 RESET_VECTOR = 0xFFFC;

    private readonly CpuBus _bus;

    public CpuRegister Register = .();
    public Stack Stack { get; private set; }

    public this(CpuBus bus)
    {
        _bus = bus;
        Stack = .(this);
    }

    public u8 ReadByte(u16 address)
    {
        return _bus.Read(address);
    }

    public Result<void, CpuError> Step(out int outCpuCycle)
    {
        u8 opCode = FetchByte();
        OpCodeContainer.FuncExecutor funcOrNull = OpCodeContainer.GetFuncOrNull(opCode);

        if (funcOrNull == null)
        {
            outCpuCycle = 0;
            return .Err(.UnknownOpcode);
        }

        funcOrNull(this, out outCpuCycle);
        return .Ok;
    }

    public u8 FetchByte()
    {
        u8 data = _bus.Read(Register.PC);
        Register.PC++;
        return data;
    }

    public void WriteByte(u16 addr, u8 value)
    {
        _bus.Write(addr, value);
    }

    public void Reset()
    {
        u16 lo = (u16)ReadByte(RESET_VECTOR);
        u16 hi = (u16)ReadByte(RESET_VECTOR + 1);
        u16 pc = (hi << 8) | lo;
        Register.PC = pc;
    }

    public void Nmi()
    {
        Stack.PushWord(Register.PC);

        u8 s = Register.Status.Value;
        s |= (u8)E_STATUS_FLAG.FLAG_U;
        s &= ~(u8)E_STATUS_FLAG.FLAG_B;
        Stack.PushByte(s);

        Register.Status.I = true;

        const int NMI_VECTOR = 0xFFFA;
        u16 lo = (u16)ReadByte(NMI_VECTOR);
        u16 hi = (u16)ReadByte(NMI_VECTOR + 1);
        Register.PC = hi << 8 | lo;
    }

    public override void ToString(String strBuffer)
    {
        Register.ToString(strBuffer);
    }
}