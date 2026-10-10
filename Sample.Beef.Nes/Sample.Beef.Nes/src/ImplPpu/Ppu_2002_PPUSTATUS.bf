namespace Sample.Beef.Nes.ImplPpu;

extension Ppu
{
    private u8 _Read_PPUSTATUS()
    {
        u8 status = PpuRegister.PPUSTATUS.Value;
        PpuRegister.PPUSTATUS.FLAG_VBLANK = false;
        LoopyRegister.W = false;
        return status;
    }
}