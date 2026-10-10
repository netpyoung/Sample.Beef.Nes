namespace Sample.Beef.Nes.ImplPpu;

extension Ppu
{
    u8[256] _OAM;

    private u8 _Read_OAMDATA()
    {
        return _OAM[PpuRegister.OAMADDR];
    }

    void _Write_OAMDATA(u8 v)
    {
        _OAM[PpuRegister.OAMADDR] = v;
        PpuRegister.OAMADDR += 1;
    }
}