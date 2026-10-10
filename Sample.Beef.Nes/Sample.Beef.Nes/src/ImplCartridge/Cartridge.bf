using System;
using System.IO;
using Sample.Beef.Nes.ImplMapper;
using System.Collections;

namespace Sample.Beef.Nes.ImplCartridge;

public sealed class Cartridge
{
    public Header_iNes _header;

    private List<u8> _data = null ~ delete _;
    private readonly u8[] _chrRamData = null ~ delete _;
    private readonly u8[] _chrRomData = null ~ delete _;

    public Span<u8> PrgRom;
    public Span<u8> ChrRom;
    public Span<u8> ChrRam;

    public int MapperId { get; }
    public bool IsBattery { get; }
    public E_MIRROR_MODE MirrorMode { get; }
    public bool IsUseChrRam { get; }
    public IMapper Mapper { get; } = null ~ delete _;

    public static Cartridge CreateFromPath(StringView path)
    {
        if (!File.Exists(path))
        {
            Runtime.FatalError(scope $"!File.Exists(path) - {path}");
        }

        List<u8> data = new List<uint8>();
        if (File.ReadAll(path, data) case .Err(let err))
        {
            Runtime.FatalError(scope $"err - {err}");
        }
        return new Cartridge(data);
    }

    public static Cartridge CreateDummyCartridge()
    {
        List<u8> data = new List<uint8>(16 + 16 * 1024);
        data.Resize(16 + 16 * 1024);
        data[0] = (u8)'N';
        data[1] = (u8)'E';
        data[2] = (u8)'S';
        data[3] = 0x1A;
        data[4] = 1; // 16KB PRG
        return new Cartridge(data);
    }

    public this(List<u8> data)
    {
        if (Header_iNes.Validate(data) case .Err(let err))
        {
            Runtime.FatalError(scope $"err - {err}");
        }

        Header_iNes header = ?;
        Internal.MemCpy(&header, data.Ptr, Header_iNes.HEADER_SIZE);

        int prgStart;
        if (header.IsTrainer())
        {
            prgStart = Header_iNes.HEADER_SIZE + Header_iNes.TRAINER_SIZE;
        }
        else
        {
            prgStart = Header_iNes.HEADER_SIZE;
        }

        int prgSize = header.GetPrgSize();
        PrgRom = data[prgStart ..< prgStart + prgSize];

        int chrSize = header.GetChrSize();
        if (chrSize > 0)
        {
            _chrRamData = new u8[0];

            ChrRam = _chrRamData;
            ChrRom = data[prgStart + prgSize ..< prgStart + prgSize + chrSize];
            IsUseChrRam = false;
        }
        else
        {
            _chrRamData = new u8[Header_iNes.CHR_BLOCK_SIZE];
            _chrRomData = new u8[8192]; // 8kb

            ChrRam = _chrRamData;
            ChrRom = _chrRomData;
            IsUseChrRam = true;
        }

        _data = data;
        _header = header;
        Mapper = new Mapper000(this);
        MapperId = header.GetMapperId();
        MirrorMode = header.GetMirrorMode();
        IsBattery = header.IsBattery();
    }

    public override void ToString(String sb)
    {
        sb.AppendF($"PRG - ROM: {PrgRom.Length / 1024:00}KB ({PrgRom.Length} u8s)\n");
        if (!IsUseChrRam)
        {
            sb.AppendF($"CHR - ROM: {ChrRom.Length / 1024:00}KB ({ChrRom.Length} u8s)\n");
        }
        else
        {
            sb.AppendF($"CHR - RAM: {ChrRam.Length / 1024:00}KB ({ChrRam.Length} u8s)\n");
        }
        sb.AppendF($"Mapper: {MapperId}\n");
        sb.AppendF($"Mirror: {MirrorMode}\n");
        sb.AppendF($"Battery: {IsBattery}\n");
    }
}
