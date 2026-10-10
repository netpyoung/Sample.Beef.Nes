using System;
namespace Sample.Beef.Nes.ImplPpu;

class Ppu
{
    public PpuRegister PpuRegister;
    public PpuLoopyRegister LoopyRegister;

    public bool IsFrameReady { get; private set; }
    public int Cycle { get; private set; }
    public int Scanline { get; private set; }
    public u8[] FrameBuffer { get; private set; } = null ~ delete _;
    public u8* FrameBufferPtr { get; private set; }

    const int FRAME_BUFFER_SIZE = 256 * 240 * 4;

    readonly PpuBus _ppuBus;

    public this(PpuBus ppuBus)
    {
        _ppuBus = ppuBus;
        FrameBuffer = new u8[FRAME_BUFFER_SIZE];
        FrameBufferPtr = FrameBuffer.Ptr;
    }

    public void ClearFrameReady()
    {
        IsFrameReady = false;
    }

    public u8 Read(u16 addr)
    {
        //Debug.Assert(CpuAddress.RegionPpu.IsIn(addr));

        int ppuAddr = addr & 0b0000'0111;
        switch (ppuAddr)
        {
        case 2: return _Read_PPUSTATUS();
        case 4: return _Read_OAMDATA();
        case 7: return _Read_PPUDATA();
        default:
                //throw new NotImplementedException();
            return 0;
        }
    }

    public void Write(u16 addr, u8 data)
    {
        //Debug.Assert(CpuAddress.RegionPpu.IsIn(addr));
        int ppuAddr = addr & 0b0000'0111;
        switch (ppuAddr)
        {
        case 0: _Write_PPUCTRL(data); break;
        case 1: _Write_PPUMASK(data); break;
        case 3: _Write_OAMADDR(data); break;
        case 4: _Write_OAMDATA(data); break;
        case 5: _Write_PPUSCROLL(data); break;
        case 6: _Write_PPUADDR(data); break;
        case 7: _Write_PPUDATA(data); break;
        default:
                //throw new NotImplementedException();
            break;
        }
    }

    public void Step(out bool outIsNmiTriggerRequired)
    {
        _RenderScanLine();
        _UpdateScrollRegisters();
        _AdvanceCycle(out outIsNmiTriggerRequired);
    }

    void _AdvanceCycle(out bool outIsNmiTriggerRequired)
    {
        const int CYCLES_PER_SCANLINE = 341;
        const int VBLANK_SCANLINE = 241;
        const int PRE_RENDER_SCANLINE = 261;
        const int SCANLINES_PER_FRAME = 262;

        Cycle += 1;

        if (Cycle < CYCLES_PER_SCANLINE)
        {
            outIsNmiTriggerRequired = false;
            return;
        }

        Cycle = 0;
        Scanline += 1;
        if (Scanline >= SCANLINES_PER_FRAME) //# 262 scanlines = one frame done
        {
            Scanline = 0;
            outIsNmiTriggerRequired = false;
            return;
        }

        if (Scanline == VBLANK_SCANLINE)
        {
            PpuRegister.PPUSTATUS.FLAG_VBLANK = true;

            IsFrameReady = true;
            if (PpuRegister.PPUCTRL.FLAG_NMI_ENABLED)
            {
                outIsNmiTriggerRequired = true;
                return;
            }
        }

        if (Scanline == PRE_RENDER_SCANLINE)
        {
            PpuRegister.PPUSTATUS.FLAG_VBLANK = false;
            PpuRegister.PPUSTATUS.FLAG_SPRITE_0_HIT = false;

            outIsNmiTriggerRequired = false;
            return;
        }

        outIsNmiTriggerRequired = false;
    }

    void _RenderScanLine()
    {
        if (!(Scanline < Display.HEIGHT && Cycle == 0))
        {
            return;
        }

        int y = Scanline;
        for (int x = 0; x < Display.WIDTH; ++x)
        {
            int bg_palette;
            int bg_color;
            if (PpuRegister.PPUMASK.FLAG_ENABLE_BACKGROUND)
            {
                _GetPalette_Background(x, out bg_palette, out bg_color);
            }
            else
            {
                bg_palette = 0;
                bg_color = 0;
            }

            int spr_color;
            int spr_palette;
            bool is_spr_behind;
            if (PpuRegister.PPUMASK.FLAG_ENABLE_SPRITE)
            {
                _GetPalette_Sprite(x, y, out spr_palette, out spr_color, out is_spr_behind);
            }
            else
            {
                spr_color = 0;
                spr_palette = 0;
                is_spr_behind = false;
            }

            u8 color;
            if (spr_color != 0 && (bg_color == 0 || !is_spr_behind))
            {
                color = _PaletteColor_Sprite(spr_palette, spr_color);
            }
            else
            {
                color = _PaletteColor_Background(bg_palette, bg_color);
            }

            _SetPixel(x, y, color);
        }

        if (PpuRegister.PPUMASK.FLAG_ENABLE_BACKGROUND && PpuRegister.PPUMASK.FLAG_ENABLE_SPRITE)
        {
            _CheckSprite0Hit(y);
        }
    }

    private u8 _PaletteColor_Sprite(int spr_palette, int spr_color)
    {
        if (spr_color == 0)
        {
            return _ppuBus.VramReadData(PpuAddress.ADDRESS_PALETTE_START);
        }
        else
        {
            return _ppuBus.VramReadData(PpuAddress.ADDRESS_PALETTE_START + (u16)(spr_palette + 4) * 4 + (u16)spr_color);
        }
    }

    private void _GetPalette_Sprite(int x, int y, out int outSprPalette, out int outSprColor, out bool outIsSprBehind)
    {
        const int SPRITES_TOTAL = 64;
        const int MAX_SPRITES_PER_SCANLINE = 8;
        const int SPRITE_BYTES = 4;
        const int SPRITE_Y_OFFSET = 1;
        const int PIXELS_PER_TILE = 8;

        int count = 0;
        for (int i = 0; i < SPRITES_TOTAL; ++i)
        {
            if (count >= MAX_SPRITES_PER_SCANLINE)
            {
                break;
            }

            int offset = i * SPRITE_BYTES;
            int sprite_y = (int)_OAM[offset] + SPRITE_Y_OFFSET;
            if (!(sprite_y <= y && y < sprite_y + PIXELS_PER_TILE))
            {
                continue;
            }
            count += 1;

            int sprite_x = (int)_OAM[offset + 3];
            if (!(sprite_x <= x && x < sprite_x + PIXELS_PER_TILE))
            {
                continue;
            }

            u8 sprite_tile = _OAM[offset + 1];
            u8 sprite_attr = _OAM[offset + 2];

            int col = x - sprite_x;
            int row = y - sprite_y;
            const int SPRITE_FLIP_H = 0b0100'0000; // 0x40; // # Bit 6: horizontal flip
            const int SPRITE_FLIP_V = 0b1000'0000; // 0x80; // # Bit 7: vertical flip
            if ((sprite_attr & SPRITE_FLIP_H) != 0)
            {
                col = (PIXELS_PER_TILE - 1) - col;
            }
            if ((sprite_attr & SPRITE_FLIP_V) != 0)
            {
                row = (PIXELS_PER_TILE - 1) - row;
            }

            int color = sprite_tile_pixel(sprite_tile, row, col);
            if (color == 0)
            {
                continue;
            }

            const int SPRITE_PALETTE_MASK = 0b0000'0011; // 0x03; // # Bits 0-1 of attribute byte
            const int SPRITE_BEHIND_BG = 0b0010'0000; // 0x20; //  # Bit 5: priority (0=front, 1=behind bg)
            u8 palette = (sprite_attr & SPRITE_PALETTE_MASK);
            bool isBehind = (sprite_attr & SPRITE_BEHIND_BG) != 0;

            outSprPalette = palette;
            outSprColor = color;
            outIsSprBehind = isBehind;
            return;
        }

        outSprPalette = 0;
        outSprColor = 0;
        outIsSprBehind = false;
    }

    void _GetPalette_Background(int x, out int outBgPalette, out int outBgColor)
    {
        int PIXELS_PER_TILE = 8;
        int TILES_PER_ROW = 32;

        int scrollX = x + (int)LoopyRegister.FineX;
        int tile_column = LoopyRegister.V.CoarseX + (scrollX / PIXELS_PER_TILE);
        int pixel_in_tile = scrollX % PIXELS_PER_TILE;
        int nametable = LoopyRegister.V.Nametable;

        if (tile_column >= TILES_PER_ROW)
        {
            tile_column -= TILES_PER_ROW;
            nametable ^= 1;
        }

        u16 nametable_address = PpuAddress.ADDRESS_NAMETABLE_START + (u16)nametable * 1024;
        u16 tile_address = (u16)(nametable_address + (LoopyRegister.V.CoarseY * TILES_PER_ROW) + tile_column);
        u8 tile_index = _ppuBus.VramReadData(tile_address);

        int color = _TilePixel(tile_index, LoopyRegister.V.FineY, pixel_in_tile);
        if (color == 0)
        {
            outBgColor = 0;
            outBgPalette = 0;
        }
        else
        {
            outBgColor = color;
            outBgPalette = _TilePalette(nametable_address, tile_column, LoopyRegister.V.CoarseY);
        }
    }

    int _TilePixel(u8 tile_index, int tile_row, int pixel_in_tile)
    {
        const int PIXELS_PER_TILE = 8;
        const int BITPLANE_OFFSET = 8;
        const int BYTES_PER_TILE = 16;

        u16 bitplane_address = (u16)(PpuRegister.PPUCTRL.GetBgPatternTableAddress() + ((int)tile_index * BYTES_PER_TILE) + tile_row);
        u8 lo_bitplane = _ppuBus.VramReadData(bitplane_address);
        u8 hi_bitplane = _ppuBus.VramReadData(bitplane_address + BITPLANE_OFFSET);

        //# Bit 7 = leftmost pixel, bit 0 = rightmost
        int bit = (PIXELS_PER_TILE - 1) - pixel_in_tile;
        u16 lo = (lo_bitplane >> bit) & 1;
        u16 hi = (hi_bitplane >> bit) & 1;
        return (hi << 1) | lo;
    }

    int _TilePalette(u16 nametable_address, int tile_column, int tile_row)
    {
        int ATTRIBUTE_TABLE_OFFSET = 960; // 32*30 tile bytes before the 64 attribute bytes
        int TILES_PER_ROW = 32;
        int COLORS_PER_PALETTE = 4;

        int attribute_column = tile_column / 4;
        int attribute_row = tile_row / 4;
        u16 attribute_address = (u16)(nametable_address + ATTRIBUTE_TABLE_OFFSET + attribute_row * (TILES_PER_ROW / 4) + attribute_column);
        int attribute_byte = (int)_ppuBus.VramReadData(attribute_address);

        int right = (tile_column / 2) & 1; // # 0 = left half, 1 = right half
        int bottom = (tile_row / 2) & 1; // # 0 = top half, 1 = bottom half
        int shift = (bottom * 2 + right) * 2;

        return (attribute_byte >> shift) & (COLORS_PER_PALETTE - 1);
    }

    u8 _PaletteColor_Background(int bg_palette, int bg_color)
    {
        if (bg_color == 0)
        {
            return _ppuBus.VramReadData(PpuAddress.ADDRESS_PALETTE_START);
        }
        else
        {
            return _ppuBus.VramReadData(PpuAddress.ADDRESS_PALETTE_START + (u16)bg_palette * 4 + (u16)bg_color);
        }
    }

    void _SetPixel(int x, int y, u8 color)
    {
        int offset = (x + y * Display.WIDTH) * 4;
        rgb rgb = Display.PALETTE[color & 0b0011'1111]; // & 0x3F

        // # RGBA format - A is always 255 (opaque)
        FrameBuffer[offset + 0] = rgb.r;
        FrameBuffer[offset + 1] = rgb.g;
        FrameBuffer[offset + 2] = rgb.b;
        FrameBuffer[offset + 3] = 255;
    }

    void _UpdateScrollRegisters()
    {
        if (!(PpuRegister.PPUMASK.FLAG_ENABLE_BACKGROUND || PpuRegister.PPUMASK.FLAG_ENABLE_SPRITE))
        {
            return;
        }

        const int PRE_RENDER_SCANLINE = 261;
        if (!(Scanline < Display.HEIGHT || Scanline == PRE_RENDER_SCANLINE))
        {
            return;
        }

        const int DOT_FINE_Y_INCREMENT = 256;
        if (Cycle == DOT_FINE_Y_INCREMENT)
        {
            LoopyRegister.V.IncFineY();
            return;
        }

        const int DOT_COPY_HORIZONTAL = 257;
        if (Cycle == DOT_COPY_HORIZONTAL)
        {
            LoopyRegister.V.CopyHorizontalFrom(LoopyRegister.T);
            return;
        }

        if (Scanline == PRE_RENDER_SCANLINE)
        {
            const int DOT_COPY_VERTICAL_START = 280;
            const int DOT_COPY_VERTICAL_END = 304;
            if (DOT_COPY_VERTICAL_START <= Cycle && Cycle <= DOT_COPY_VERTICAL_END)
            {
                LoopyRegister.V.CopyVerticalFrom(LoopyRegister.T);
                return;
            }
        }
    }

    public void Oam_Dma(Span<u8> data)
    {
        data.CopyTo(_OAM);
    }

    void _CheckSprite0Hit(int y)
    {
        if (PpuRegister.PPUSTATUS.FLAG_SPRITE_0_HIT)
        {
            return;
        }

        const int SPRITE_Y_OFFSET = 1;
        int sprite_y = (int)_OAM[0] + SPRITE_Y_OFFSET;

        const int PIXELS_PER_TILE = 8;
        if (y < sprite_y || sprite_y + PIXELS_PER_TILE <= y)
        {
            return;
        }

        u8 sprite_tile = _OAM[1];
        u8 sprite_attr = _OAM[2];
        int sprite_x = (int)_OAM[3];

        int row;
        if ((sprite_attr & 0x80) != 0) // vertical flip
        {
            row = (PIXELS_PER_TILE - 1) - (y - sprite_y);
        }
        else
        {
            row = y - sprite_y;
        }

        for (int i = 0; i < PIXELS_PER_TILE; ++i)
        {
            int screen_x = sprite_x + i;
            if (screen_x >= 255)
            {
                continue;
            }

            int flip_col;
            if ((sprite_attr & 0x40) != 0)
            {
                flip_col = (PIXELS_PER_TILE - 1) - i;
            }
            else
            {
                flip_col = i;
            }

            int sprite_color = sprite_tile_pixel(sprite_tile, row, flip_col);
            if (sprite_color == 0) // # Transparent sprite pixel;
            {
                continue;
            }

            _GetPalette_Background(screen_x, let bgPalette, let bg_color);
            if (bg_color == 0) // # Transparent background pixel;
            {
                continue;
            }

            PpuRegister.PPUSTATUS.FLAG_SPRITE_0_HIT = true;
            return;
        }
    }

    private int sprite_tile_pixel(u8 tile_index, int tile_row, int pixel_in_tile)
    {
        const int PIXELS_PER_TILE = 8;
        const int BYTES_PER_TILE = 16;
        const int BITPLANE_OFFSET = 8;

        u16 bitplane_address = (u16)(PpuRegister.PPUCTRL.GetSpritePatternTableAddress() + tile_index * BYTES_PER_TILE + tile_row);
        u8 lo_bitplane = _ppuBus.VramReadData(bitplane_address);
        u8 hi_bitplane = _ppuBus.VramReadData(bitplane_address + BITPLANE_OFFSET);

        int bit = (PIXELS_PER_TILE - 1) - pixel_in_tile;
        u16 lo = (lo_bitplane >> bit) & 1;
        u16 hi = (hi_bitplane >> bit) & 1;
        u16 ret = (hi << 1) | lo;
        return ret;
    }
}