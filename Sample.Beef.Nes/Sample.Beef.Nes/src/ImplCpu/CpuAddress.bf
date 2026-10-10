namespace Sample.Beef.Nes.ImplCpu;

class CpuAddress
{
    public readonly static u16 ADDRESS_RAM_START = 0x0000;
    public readonly static u16 ADDRESS_RAM_MIRROR_END = 0x1FFF;

    public readonly static u16 ADDRESS_PPU_START = 0x2000;
    public readonly static u16 ADDRESS_PPU_MIRROR_END = 0x3FFF;

    public readonly static u16 ADDRESS_PRG_ROM_START = 0x8000;
    public readonly static u16 ADDRESS_PRG_ROM_END = 0xFFFF;

    public readonly static u16 ADDRESS_APU_START = 0x4000;
    public readonly static u16 ADDRESS_APU_END = 0x4013;
    public readonly static u16 ADDRESS_APU_STATUS = 0x4015;
    public readonly static u16 ADDRESS_APU_FRAME_COUNTER = 0x4017;

    public readonly static u16 OAM_DMA = 0x4014;
    public readonly static u16 CONTROLLER_1 = 0x4016;
    public readonly static u16 CONTROLLER_2 = 0x4017;

    public readonly static Region RegionRam = .(ADDRESS_RAM_START, ADDRESS_RAM_MIRROR_END);
    public readonly static Region RegionApu = .(ADDRESS_APU_START, ADDRESS_APU_END);
    public readonly static Region RegionPpu = .(ADDRESS_PPU_START, ADDRESS_PPU_MIRROR_END);
    public readonly static Region RegionPrgRom = .(ADDRESS_PRG_ROM_START, ADDRESS_PRG_ROM_END);

    public sealed struct Region
    {
        public u16 Start { get; }
        public u16 End { get; }

        public this(u16 start, u16 end)
        {
            Start = start;
            End = end;
        }

        public bool IsIn(u16 addr)
        {
            return Start <= addr && addr <= End;
        }
    }
}