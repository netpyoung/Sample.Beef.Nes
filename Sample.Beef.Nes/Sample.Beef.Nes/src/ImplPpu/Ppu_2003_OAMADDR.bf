namespace Sample.Beef.Nes.ImplPpu;

extension Ppu
{
    void _Write_OAMADDR(u8 data)
    {
        PpuRegister.OAMADDR = data;
    }
}