using System;

namespace Sample.Beef.Nes.ImplPpu.PpuRegisters;

struct PPUSTATUS
{
    public enum E_FLAG : u8
    {
        // https://www.nesdev.org/wiki/PPU_registers#PPUSTATUS_-_Rendering_events_($2002_read)
        //7  bit  0
        //---- ----
        //VSOx xxxx
        //|||| ||||
        //|||+-++++- (PPU open bus or 2C05 PPU identifier)
        //||+------- Sprite overflow flag
        //| +--------Sprite 0 hit flag
        //+---------Vblank flag, cleared on read.Unreliable; see below.

        SPRITE_0_HIT = 0b0100'0000, // 0x40
        VBLANK = 0b1000'0000, // 0x80
    }

    u8 _value;

    public u8 Value => _value;

    public this(u8 value)
    {
        _value = value;
    }

    public bool FLAG_VBLANK
    {
        get
        {
            return (_value & (u8)E_FLAG.VBLANK) != 0;
        }
        set mut
        {
            if (value)
            {
                _value |= (u8)E_FLAG.VBLANK;
            }
            else
            {
                _value &= ~(u8)E_FLAG.VBLANK;
            }
        }
    }

    public bool FLAG_SPRITE_0_HIT
    {
        get
        {
            return (_value & (u8)E_FLAG.SPRITE_0_HIT) != 0;
        }
        set mut
        {
            if (value)
            {
                _value |= (u8)E_FLAG.SPRITE_0_HIT;
            }
            else
            {
                _value &= ~(u8)E_FLAG.SPRITE_0_HIT;
            }
        }
    }

    public override void ToString(String sb)
    {
        sb.Append(_value);
    }
}
