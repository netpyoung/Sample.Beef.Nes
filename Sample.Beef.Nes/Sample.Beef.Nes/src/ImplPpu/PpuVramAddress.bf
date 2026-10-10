using System;
namespace Sample.Beef.Nes.ImplPpu;

struct PpuVramAddress
{
    // https://www.nesdev.org/wiki/PPU_registers#PPUADDR
    //1st write  2nd write
    //15 bit  8  7  bit  0
    //---- ----  ---- ----
    //..AA AAAA  AAAA AAAA
    //  || ||||  |||| ||||
    //..++-++++--++++-++++- VRAM address

    // https://www.nesdev.org/wiki/PPU_scrolling#PPU_internal_registers
    //.yyy NNYY  YYYX XXXX
    // ||| ||||  |||+-++++-- coarse X scroll
    // ||| ||++--+++-------- coarse Y scroll
    // ||| ++--------------- nametable select
    //.+++------------------ fine Y scroll

    //..AA AAAA  AAAA AAAA
    readonly static u16 VRAM_ADDRESS_MASK = 0b0011'1111'1111'1111;

    //.yyy NNYY  YYYX XXXX
    readonly static u16 MASK_COARSE_X = 0b0000'0000'0001'1111;
    readonly static u16 MASK_COARSE_Y = 0b0000'0011'1110'0000;
    readonly static u16 MASK_NAMETABLE_X = 0b0000'0100'0000'0000; // horizontal
    readonly static u16 MASK_NAMETABLE_Y = 0b0000'1000'0000'0000; // vertical
    readonly static u16 MASK_NAMETABLE__ = 0b0000'1100'0000'0000;
    readonly static u16 MASK_FINE_Y = 0b0111'0000'0000'0000;

    u16 _value;

    public int CoarseX => (_value & MASK_COARSE_X);
    public int CoarseY => (_value & MASK_COARSE_Y) >> 5;
    public int NametableX => (_value & MASK_NAMETABLE_X) >> 10;
    public int NametableY => (_value & MASK_NAMETABLE_Y) >> 11;
    public int Nametable => (_value & MASK_NAMETABLE__) >> 10;

    public int FineY => (_value & MASK_FINE_Y) >> 12;

    public u16 Addr => _value;

    public this(u16 value)
    {
        _value = value;
    }

    public void AddWithAddressMask(u16 value) mut
    {
        _value += value;
        _value &= VRAM_ADDRESS_MASK;
    }

    public void SetNameTable(u8 nameTable) mut
    {
        _value &= ~MASK_NAMETABLE__;
        _value |= ((u16)nameTable << 10);
    }

    public void SetCoarseX(u16 coarse) mut
    {
        _value &= ~MASK_COARSE_X;

        _value |= coarse;
    }

    public void SetFineY(u8 fineY) mut
    {
        _value &= ~MASK_FINE_Y;

        //fineY &= 0x07; // 0b0000'0111
        _value |= ((u16)fineY << 12);
    }

    public void SetCoarseY(u16 coarseY) mut
    {
        _value &= ~MASK_COARSE_Y;

        //coarseY &= 0x001F; // 0b0000'0000'0001_1111
        _value |= (u16)(coarseY << 5);
    }

    public void WriteAddress_lo(u8 data) mut
    {
        _value &= (u16)0b1111'1111'0000'0000; // 0xFF00 - clear address lo
        _value |= (u16)data;
    }

    public void WriteAddress_hi(u8 data) mut
    {
        _value &= (u16)0b0000'0000'1111'1111; // 0x00FF - clear address hi
        _value |= ((u16)data & 0b0000'0000'0011'1111) << 8; // 0x3F == 0b0011_1111
    }

    public void IncFineY() mut
    {
        const int MAX_FINE_Y = 7;
        if (FineY < MAX_FINE_Y)
        {
            const int FINE_Y_UNIT = 0x1000;
            _value += FINE_Y_UNIT;
            return;
        }

        _value &= ~MASK_FINE_Y;

        int y = CoarseY;
        const int MAX_COARSE_Y = 29;
        if (y == MAX_COARSE_Y)
        {
            _value &= ~MASK_COARSE_Y;
            _value ^= MASK_NAMETABLE_Y;
        }
        else if (y == 31) // # attribute table area, wraps without flipping (hardware quirk)
        {
            _value &= ~MASK_COARSE_Y;
        }
        else
        {
            _value &= ~MASK_COARSE_Y;

            _value |= (uint16)((y + 1) << 5);
        }
    }

    public void CopyHorizontalFrom(PpuVramAddress t) mut
    {
        u16 MASK_HORIZONTAL = 0b0000'0100'0001'1111; //  0x041F; # Horizontal bits: coarse X + horizontal nametable bit
        _value &= ~MASK_HORIZONTAL;
        _value |= (t._value & MASK_HORIZONTAL);
    }

    public void CopyVerticalFrom(PpuVramAddress t) mut
    {
        u16 MASK_VERTICAL = 0b0111'1011'1110'0000; //0x7BE0; # Vertical bits: coarse Y + fine Y + vertical nametable bit
        _value &= ~MASK_VERTICAL;
        _value |= (t._value & MASK_VERTICAL);
    }

    public override void ToString(String sb)
    {
        sb.Append(_value);
    }
}