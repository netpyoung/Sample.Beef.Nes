namespace Sample.Beef.Nes.ImplPpu;

extension Ppu
{
    void _Write_PPUSCROLL(u8 data)
    {
        if (LoopyRegister.W)
        {
            u16 coarse = (u16)data >> 3;
            LoopyRegister.T.SetCoarseY(coarse);

            u8 fine = data & 0b0000'0111;
            LoopyRegister.T.SetFineY(fine);
        }
        else
        {
            u16 coarse = (u16)data >> 3;
            LoopyRegister.T.SetCoarseX(coarse);

            u8 fine = data & 0b0000'0111;
            LoopyRegister.FineX = fine;
        }

        LoopyRegister.W = !LoopyRegister.W;
    }
}