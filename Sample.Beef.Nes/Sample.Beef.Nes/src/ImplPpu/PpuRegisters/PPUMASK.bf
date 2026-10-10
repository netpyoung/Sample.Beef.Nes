using System;

namespace Sample.Beef.Nes.ImplPpu.PpuRegisters;

struct PPUMASK
{
    public enum E_FLAG : u8
    {
        // https://www.nesdev.org/wiki/PPU_registers#PPUMASK_-_Rendering_settings_($2001_write)
        //7  bit  0
        //---- ----
        //BGRs bMmG
        //|||| ||||
        //|||| |||+- Greyscale (0: normal color, 1: greyscale)
        //|||| ||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
        //|||| |+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
        //|||| +---- 1: Enable background rendering
        //|||+------ 1: Enable sprite rendering
        //|| +-------Emphasize red(green on PAL/Dendy)
        //|+-------- Emphasize green(red on PAL/Dendy)
        //+--------- Emphasize blue
        ENABLE_BACKGROUND = 0b0000'1000,
        ENABLE_SPRITE = 0b0001'0000,
    }

    readonly u8 _value;
    public readonly u8 Value => _value;

    public this(u8 value)
    {
        _value = value;
    }


    public readonly bool FLAG_ENABLE_BACKGROUND
    {
        get
        {
            return (_value & (u8)E_FLAG.ENABLE_BACKGROUND) != 0;
        }
    }

    public readonly bool FLAG_ENABLE_SPRITE
    {
        get
        {
            return (_value & (u8)E_FLAG.ENABLE_SPRITE) != 0;
        }
    }

    public override void ToString(String sb)
    {
        sb.Append(_value);
    }
}