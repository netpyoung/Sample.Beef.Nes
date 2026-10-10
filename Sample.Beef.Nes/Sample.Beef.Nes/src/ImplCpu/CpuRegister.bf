using System;

namespace Sample.Beef.Nes.ImplCpu;

struct CpuRegister
{
    public u8 A = 0;
    public u8 X = 0;
    public u8 Y = 0;
    public u8 SP = 0xFD; // 0xFF - 3
    public u16 PC = 0;

    public StatusRegister Status;

    public this()
    {
        Status = 0b0010'0100; // ..U._.I..
    }

    public override void ToString(String strBuffer)
    {
        strBuffer.AppendF($"A=0x{A:X2} X=0x{X:X2} Y=0x{Y:X2} SP=0x{SP:X2} PC=0x{PC:X4}  [{Status}]");
    }
}