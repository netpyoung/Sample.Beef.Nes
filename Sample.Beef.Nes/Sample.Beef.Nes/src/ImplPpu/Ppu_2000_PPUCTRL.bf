using Sample.Beef.Nes.ImplPpu.PpuRegisters;

namespace Sample.Beef.Nes.ImplPpu;

extension Ppu
{
    void _Write_PPUCTRL(u8 data)
    {
        PpuRegister.PPUCTRL = .(data);
        u8 nameTable = PpuRegister.PPUCTRL.BASE_NAMETABLE_ADDRESS;
        LoopyRegister.T.SetNameTable(nameTable);
    }
}