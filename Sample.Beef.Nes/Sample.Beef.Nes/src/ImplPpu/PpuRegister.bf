using System;
using Sample.Beef.Nes.ImplPpu.PpuRegisters;

namespace Sample.Beef.Nes.ImplPpu;

struct PpuRegister
{
    public PPUCTRL PPUCTRL; //$2000 PPUCTRL
    public PPUMASK PPUMASK; //$2001 PPUMASK
    public PPUSTATUS PPUSTATUS; //$2002 PPUSTATUS
    public u8 OAMADDR; //$2003 OAMADDR

    //$2004 OAMDATA
    //$2005 PPUSCROLL - x/y
    //$2006 PPUADDR - addr
    //$2007 PPUDATA

    public override void ToString(String sb)
    {
        sb.AppendF($"PPUCTRL:{PPUCTRL} PPUMASK:{PPUMASK} PPUSTATUS:{PPUSTATUS} OAMADDR:{OAMADDR}");
    }
}
