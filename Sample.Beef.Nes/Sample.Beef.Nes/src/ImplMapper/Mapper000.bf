using Sample.Beef.Nes.ImplCartridge;
using System;
namespace Sample.Beef.Nes.ImplMapper;

class Mapper000 : IMapper
{
    readonly static u16 PRG_MASK_16K = 0x3FFF;
    readonly static u16 PRG_MASK_32K = 0x7FFF;
    readonly static u16 CHR_MASK_8K = 0x1FFF;

    Cartridge _cartridge;
    u16 _prgMask;

    public this(Cartridge cartridge)
    {
        _cartridge = cartridge;

        if (cartridge.PrgRom.Length > Header_iNes.PRG_BLOCK_SIZE)
        {
            _prgMask = PRG_MASK_32K;
        }
        else
        {
            _prgMask = PRG_MASK_16K;
        }
    }

    public E_MIRROR_MODE? MirrorModeOrNull
    {
        get
        {
            return null;
        }
    }

    public u8 Chr_Read(u16 addr)
    {
        u16 idx = addr & CHR_MASK_8K;
        return _cartridge.ChrRom[idx];
    }

    public u8 Chr_Write(u16 addr, u8 v)
    {
        Runtime.FatalError("NotImplemented");
    }

    public u8 Prg_Read(u16 addr)
    {
        u16 idx = addr & _prgMask;
        return _cartridge.PrgRom[idx];
    }
}