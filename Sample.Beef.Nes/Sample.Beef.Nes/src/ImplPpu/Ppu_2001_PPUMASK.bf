namespace Sample.Beef.Nes.ImplPpu;

extension Ppu
{
    void _Write_PPUMASK(u8 data)
    {
        PpuRegister.PPUMASK = .(data);
    }
}