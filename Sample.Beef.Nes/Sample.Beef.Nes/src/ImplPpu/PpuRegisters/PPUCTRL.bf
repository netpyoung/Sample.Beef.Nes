using System;
namespace Sample.Beef.Nes.ImplPpu.PpuRegisters;

public struct PPUCTRL
{
    //[Flags]
    public enum E_FLAG : u8
    {
        // https://www.nesdev.org/wiki/PPU_registers#PPUCTRL_-_Miscellaneous_settings_($2000_write)
        //7  bit  0
        //---- ----
        //VPHB SINN
        //|||| ||||
        //|||| ||++- Base nametable address
        //|||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
        //|||| |+--- VRAM address increment per CPU read/write of PPUDATA
        //|||| |     (0: add 1, going across; 1: add 32, going down)
        //|||| +---- Sprite pattern table address for 8x8 sprites
        //||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
        //|||+------ Background pattern table address(0: $0000; 1: $1000)
        //||+------- Sprite size(0: 8x8 pixels; 1: 8x16 pixels – see PPU OAM#u8 1)
        //| +--------PPU master/slave select
        //|          (0: read backdrop from EXT pins; 1: output color on EXT pins)
        //+--------- Vblank NMI enable(0: off, 1: on)
        BASE_NAMETABLE_ADDRESS = 0b0000'0011,
        VRAM_INCREMENT = 0b0000'0100,
        PATTERN_TABLE_SPRITE_ADDRESS = 0b0000'1000,
        PATTERN_TABLE_BACKGROUND_ADDRESS = 0b0001'0000,
        NMI_ENABLED = 0b1000'0000,
    }

    u8 _value;
    public readonly u8 Value => _value;

    public this(u8 value)
    {
        _value = value;
    }

    public readonly u8 BASE_NAMETABLE_ADDRESS
    {
        get
        {
            u8 addr = _value & (u8)(u8)E_FLAG.BASE_NAMETABLE_ADDRESS;
            return addr;
        }
    }

    public bool FLAG_VRAM_INCREMENT
    {
        get
        {
            return (_value & (u8)(u8)E_FLAG.VRAM_INCREMENT) != 0;
        }
        set mut
        {
            if (value)
            {
                _value |= (u8)(u8)E_FLAG.VRAM_INCREMENT;
            }
            else
            {
                _value &= ~(u8)(u8)E_FLAG.VRAM_INCREMENT;
            }
        }
    }

    public bool FLAG_NMI_ENABLED
    {
        get
        {
            return (_value & (u8)(u8)E_FLAG.NMI_ENABLED) != 0;
        }
        set mut
        {
            if (value)
            {
                _value |= (u8)(u8)E_FLAG.NMI_ENABLED;
            }
            else
            {
                _value &= ~(u8)(u8)E_FLAG.NMI_ENABLED;
            }
        }
    }

    public bool FLAG_PATTERN_TABLE_SPRITE_ADDRESS
    {
        get
        {
            return (_value & (u8)(u8)E_FLAG.PATTERN_TABLE_SPRITE_ADDRESS) != 0;
        }
        set mut
        {
            if (value)
            {
                _value |= (u8)(u8)E_FLAG.PATTERN_TABLE_SPRITE_ADDRESS;
            }
            else
            {
                _value &= ~(u8)(u8)E_FLAG.PATTERN_TABLE_SPRITE_ADDRESS;
            }
        }
    }

    public bool FLAG_PATTERN_TABLE_BACKGROUND_ADDRESS
    {
        get
        {
            return (_value & (u8)(u8)E_FLAG.PATTERN_TABLE_BACKGROUND_ADDRESS) != 0;
        }
        set mut
        {
            if (value)
            {
                _value |= (u8)(u8)E_FLAG.PATTERN_TABLE_BACKGROUND_ADDRESS;
            }
            else
            {
                _value &= ~(u8)(u8)E_FLAG.PATTERN_TABLE_BACKGROUND_ADDRESS;
            }
        }
    }

    public u16 GetBgPatternTableAddress()
    {
        if (FLAG_PATTERN_TABLE_BACKGROUND_ADDRESS)
        {
            return 0x1000;
        }
        return 0x0000;
    }

    public u16 GetSpritePatternTableAddress()
    {
        if (FLAG_PATTERN_TABLE_SPRITE_ADDRESS)
        {
            return 0x1000;
        }
        return 0x0000;
    }

    public u16 GetVramIncrementAmount()
    {
        if (FLAG_VRAM_INCREMENT)
        {
            return 32;
        }
        return 1;
    }

    public override void ToString(String sb)
    {
        sb.Append(_value);
    }
}
