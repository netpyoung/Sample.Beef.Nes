using Sample.Beef.Nes.ImplCartridge;

namespace Sample.Beef.Nes.ImplPpu;

class PpuBus
{
    u8[2048] _nameTableRam;
    u8[32] _PaletteRam;

    private readonly Cartridge _cartridge;

    public this(Cartridge cartridge)
    {
        _cartridge = cartridge;
    }

    const int VRAM_MASK = 0x3FFF;

    public u8 VramReadData(u16 addr)
    {
        u16 x = addr & VRAM_MASK;

        if (PpuAddress.RegionPatternTable.IsIn(x))
        {
            return _cartridge.Mapper.Chr_Read(addr);
        }

        if (PpuAddress.RegionNametable.IsIn(x))
        {
            u16 mirroredAddr = _GetMirroredAddr(addr);
            return _nameTableRam[mirroredAddr];
        }

        if (PpuAddress.RegionPalette.IsIn(x))
        {
            u16 idx = _GetPaletteIndex(addr);
            return _PaletteRam[idx];
        }

        return 0;
    }

    public void VramWriteData(u16 addr, u8 data)
    {
        u16 x = addr & VRAM_MASK;

        if (PpuAddress.RegionPatternTable.IsIn(x))
        {
            _cartridge.Mapper.Chr_Read(addr);
            return;
        }

        if (PpuAddress.RegionNametable.IsIn(x))
        {
            u16 mirroredAddr = _GetMirroredAddr(addr);
            _nameTableRam[mirroredAddr] = data;
            return;
        }

        if (PpuAddress.RegionPalette.IsIn(x))
        {
            u8 COLOR_MASK = 0x3F;

            u16 idx = _GetPaletteIndex(addr);
            _PaletteRam[idx] = data & COLOR_MASK;
            return;
        }
    }

    private u16 _GetMirroredAddr(u16 addr)
    {
        u16 NAMETABLE_SIZE = 1024;
        u16 NAMETABLE_START = 0x2000;
        u16 NAMETABLE_AREA_MASK = 0b0000'1111'1111'1111; // 0x0FFF

        u16 relative = (addr - NAMETABLE_START) & NAMETABLE_AREA_MASK;
        u16 nametable = relative / NAMETABLE_SIZE;
        u16 offset = relative % NAMETABLE_SIZE;

        E_MIRROR_MODE mirroring;
        if (_cartridge.Mapper.MirrorModeOrNull != null)
        {
            mirroring = _cartridge.Mapper.MirrorModeOrNull.Value;
        }
        else
        {
            mirroring = _cartridge.MirrorMode;
        }

        u16 physical;
        switch (mirroring)
        {
        case E_MIRROR_MODE.VERTICAL:
            physical = nametable & 1; //   # 0,1,0,1
            break;
        case E_MIRROR_MODE.HORIZONTAL:
            physical = nametable >> 1; //  # 0,0,1,1
            break;
        case E_MIRROR_MODE.SINGLE_SCREEN_LOWER:
            physical = 0; //           # 0,0,0,0
            break;
        case E_MIRROR_MODE.SINGLE_SCREEN_UPPER:
            physical = 1; //6           # 1,1,1,1
            break;
        default:
            physical = nametable & 1;
            break;
        }

        u16 ret = physical * NAMETABLE_SIZE + offset;
        return ret;
    }

    private static u16 _GetPaletteIndex(u16 addr)
    {
        u16 PALETTE_MASK = 0b0001'1111; // 0x1F;
        u16 PALETTE_COLOR_MASK = 0b0000'0111; // 0x03;
        u16 PALETTE_SPRITE_BASE = 0b0001'0000; // 0x10;

        u16 idx = addr & PALETTE_MASK;

        if (idx >= PALETTE_SPRITE_BASE && (idx & PALETTE_COLOR_MASK) == 0)
        {
            idx -= PALETTE_SPRITE_BASE;
        }

        return idx;
    }
}