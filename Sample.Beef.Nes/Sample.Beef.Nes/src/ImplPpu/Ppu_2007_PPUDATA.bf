namespace Sample.Beef.Nes.ImplPpu;

extension Ppu
{
    u8 _ppuDataLatch = 0;

    u8 _Read_PPUDATA()
    {
        u8 ret;
        if (LoopyRegister.V.Addr >= PpuAddress.ADDRESS_PALETTE_START)
        {
            ret = _ppuBus.VramReadData(LoopyRegister.V.Addr);
            _ppuDataLatch = _ppuBus.VramReadData(LoopyRegister.V.Addr - 0x1000);
        }
        else
        {
            ret = _ppuDataLatch;
            _ppuDataLatch = _ppuBus.VramReadData(LoopyRegister.V.Addr);
        }

        LoopyRegister.V.AddWithAddressMask(PpuRegister.PPUCTRL.GetVramIncrementAmount());
        return ret;
    }

    void _Write_PPUDATA(u8 data)
    {
        _ppuBus.VramWriteData(LoopyRegister.V.Addr, data);
        LoopyRegister.V.AddWithAddressMask(PpuRegister.PPUCTRL.GetVramIncrementAmount());
    }
}