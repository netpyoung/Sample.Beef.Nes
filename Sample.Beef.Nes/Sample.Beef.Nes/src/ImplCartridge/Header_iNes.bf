using System.Diagnostics;
using System;
namespace Sample.Beef.Nes.ImplCartridge;

[Packed, Ordered]
struct Header_iNes
{
    //| u8 |                                              |
    //| ---- | -------------------------------------------- |
    //| 0-3  | "NES" followed by u8 0x1A                  |
    //| 4    | Number of PRG - ROM blocks(each block = 16KB)|
    //| 5    | Number of CHR - ROM blocks(each block = 8KB) |
    //| 6    | Flags 6                                      |
    //| 7    | Flags 7                                      |
    //| 8-15 | Padding                                      |

    public const int HEADER_SIZE = 16;
    public const int PRG_BLOCK_SIZE = 0x4000; // 16kb
    public const int CHR_BLOCK_SIZE = 0x2000; // 8kb
    public const int TRAINER_SIZE = 512;

    const int PRG_SIZE_u8 = 4;
    const int CHR_SIZE_u8 = 5;
    const int FLAGS_6_u8 = 6;
    const int FLAGS_7_u8 = 7;

    static u8[4] MAGIC = .(0x4E, 0x45, 0x53, 0x1A); // [(u8)'N', (u8)'E', (u8)'S', 0x1A]

    public u8[4] Magic;
    public u8 NumberOfPRG;
    public u8 NumberOfCHR;
    public u8 Flags6;
    public u8 Flags7;
    public u8[8] Padding;

    public enum HeaderError
    {
        case InvalidHeaderLength;
        case InvalidHeaderMagic;
    }

    public static Result<void, HeaderError> Validate(Span<u8> data)
    {
        Debug.Assert(sizeof(Header_iNes) == HEADER_SIZE);

        if (data.Length < HEADER_SIZE)
        {
            Console.Error.WriteLine(scope $"u8s.Length < HEADER_SIZE({HEADER_SIZE}) - {data.Length}");
            return .Err(.InvalidHeaderLength);
        }


        if (Internal.MemCmp(data[0 ..< 4].Ptr, &MAGIC, MAGIC.Count) != 0)
        {
            //String actual = Convert.ToHexString(u8s[0..4]);
            //String expected = Convert.ToHexString(MAGIC);
            //Runtime.FatalError(scope $"magic number: u8s[0..4].SequenceCompareTo(magic) != 0 - expected:{expected} / actual:{actual}");
            return .Err(.InvalidHeaderMagic);
        }

        return .Ok;
    }

    public int GetMapperId()
    {
        u8 lo = (u8)((u8)(Flags6 & 0b1111'0000) >> 4);
        u8 hi = (u8)(Flags7 & 0b1111'0000);
        u8 mapperId = (u8)(hi | lo);
        return mapperId;
    }

    public E_MIRROR_MODE GetMirrorMode()
    {
        if ((Flags6 & (u8)E_FLAGS_6.FOUR_SCREEN_MASK) != 0)
        {
            return E_MIRROR_MODE.FOUR_SCREEN;
        }

        if ((Flags6 & (u8)E_FLAGS_6.MIRROR_MASK) != 0)
        {
            return E_MIRROR_MODE.VERTICAL;
        }

        return E_MIRROR_MODE.HORIZONTAL;
    }

    public int GetPrgSize()
    {
        int prgSize = NumberOfPRG * PRG_BLOCK_SIZE;
        return prgSize;
    }

    public int GetChrSize()
    {
        int chrSize = NumberOfCHR * CHR_BLOCK_SIZE;
        return chrSize;
    }

    public bool IsBattery()
    {
        return (Flags6 & (u8)E_FLAGS_6.BATTERY_MASK) != 0;
    }

    public bool IsTrainer()
    {
        return (Flags6 & (u8)E_FLAGS_6.TRAINER_MASK) != 0;
    }
}

public enum E_FLAGS_6 : u8
{
    MIRROR_MASK = 0b0000'0001, // 0 = horizontal, 1 = vertical
    BATTERY_MASK = 0b0000'0010, // 1 = battery-backed RAM
    TRAINER_MASK = 0b0000'0100, // 1 = 512-u8 trainer before PRG
    FOUR_SCREEN_MASK = 0b0000'1000, // 1 = four-screen VRAM
}

public enum E_MIRROR_MODE
{
    HORIZONTAL,
    VERTICAL,
    FOUR_SCREEN,
    SINGLE_SCREEN_LOWER,
    SINGLE_SCREEN_UPPER,
}
