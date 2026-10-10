namespace Sample.Beef.Nes.ImplCpu;

struct Stack
{
    Cpu _cpu;

    public this(Cpu cpu)
    {
        _cpu = cpu;
    }

    public void PushByte(u8 v)
    {
        u16 addr = (u16)_cpu.Register.SP;
        addr |= 0x0100;

        _cpu.WriteByte(addr, v);
        _cpu.Register.SP--;
    }

    public u8 PopByte()
    {
        _cpu.Register.SP++;

        u16 addr = (u16)_cpu.Register.SP;
        addr |= 0x0100;

        u8 v = _cpu.ReadByte(addr);
        return v;
    }

    public void PushWord(u16 v)
    {
        u8 v1 = (u8)(v >> 8);
        u8 v2 = (u8)(v & 0xFF);
        PushByte(v1);
        PushByte(v2);
    }

    public u16 PopWord()
    {
        u16 lo = (u16)PopByte();
        u16 hi = (u16)PopByte();
        return (hi << 8) | lo;
    }
}