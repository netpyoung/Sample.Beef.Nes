using Sample.Beef.Nes.ImplCartridge;

namespace Sample.Beef.Nes.ImplMapper;

public interface IMapper
{
    E_MIRROR_MODE? MirrorModeOrNull { get; }

    u8 Prg_Read(u16 addr);
    u8 Chr_Read(u16 addr);
    u8 Chr_Write(u16 addr, u8 v);
}
