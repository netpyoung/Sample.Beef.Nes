using System;
using Sample.Beef.Nes.ImplCartridge;
using Sample.Beef.Nes.ImplPpu;

namespace Sample.Beef.Nes.Tests.TestPpu;

class Test_Ppu
{
    private static Ppu PreparePpu()
    {
        Cartridge cartridge = Cartridge.CreateDummyCartridge();
        PpuBus bus = new PpuBus(cartridge);
        Ppu ppu = new Ppu(bus);
        return ppu;
    }

    static void CleanupPpu(Ppu ppu)
    {
        delete ppu.[Friend]_ppuBus.[Friend]_cartridge;
        delete ppu.[Friend]_ppuBus;
        delete ppu;
    }

    readonly static u8 FLAG_VBLANK = 0b1000'0000; // 0x80

    [Test]
    public static void Test01()
    {
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        // # Test 1: VBlank fires at the right scanline
        for (int i = 0; i < 241 * 341 - 1; ++i)
        {
            ppu.Step(let isNmiTriggerRequired);
        }

        Assert.False(ppu.IsFrameReady);
        Assert.False(ppu.PpuRegister.PPUSTATUS.FLAG_VBLANK);

        ppu.Step(let isNmiTriggerRequired);
        Assert.True(ppu.IsFrameReady);
        Assert.True(ppu.PpuRegister.PPUSTATUS.FLAG_VBLANK);

        // # Test 2: read_status clears VBlank and resets latch
        u8 result;

        ppu.Write(0x2005, 0x00);
        Assert.True(ppu.LoopyRegister.W);

        result = ppu.Read(0x2002);

        Assert.NotEqual<u8>(result & FLAG_VBLANK, 0);
        Assert.False(ppu.PpuRegister.PPUSTATUS.FLAG_VBLANK);
        Assert.False(ppu.LoopyRegister.W);
    }

    [Test]
    public static void Test03()
    {
        // # Test 3: NMI callback fires
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        ppu.Write(0x2000, 0x80);

        int nmiCount = 0;
        for (int i = 0; i < 341 * 262; ++i)
        {
            ppu.Step(let isNmiTriggerRequired);
            if (isNmiTriggerRequired)
            {
                nmiCount++;
            }
        }

        Assert.Equal(1, nmiCount);
    }

    [Test]
    public static void Test04()
    {
        // # Test 4: NMI does NOT fire when disabled
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        int nmiCount = 0;
        for (int i = 0; i < 341 * 262; ++i)
        {
            ppu.Step(let isNmiTriggerRequired);
            if (isNmiTriggerRequired)
            {
                nmiCount++;
            }
        }

        Assert.Equal(0, nmiCount);
    }

    [Test]
    public static void Test05()
    {
        // # Test 5: PPUSCROLL sets loopy registers
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        ppu.Write(0x2005, 43);
        Assert.Equal<u8>(3, ppu.LoopyRegister.FineX);
        Assert.Equal<u16>(5, ppu.LoopyRegister.T.Addr & 0x001F);

        ppu.Write(0x2005, 43);
        Assert.Equal(5, ppu.LoopyRegister.T.CoarseY);
        Assert.Equal(3, ppu.LoopyRegister.T.FineY);
    }

    [Test]
    public static void Test06()
    {
        // # Test 6: PPUADDR sets v on second write
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        ppu.Write(0x2006, 0x21);
        ppu.Write(0x2006, 0x08);

        Assert.Equal<u16>(0x2108, ppu.LoopyRegister.V.Addr);
    }

    [Test]
    public static void Test07()
    {
        // # Test 7: PPUDATA write/read through VRAM
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        ppu.Write(0x2006, 0x20);
        ppu.Write(0x2006, 0x00);
        ppu.Write(0x2007, 0x42);

        ppu.Write(0x2006, 0x20);
        ppu.Write(0x2006, 0x00);
        ppu.Read(0x2007);
        u8 result = ppu.Read(0x2007);
        Assert.Equal<u8>(0x42, result);
    }

    [Test]
    public static void Test08()
    {
        // # Test 8: Palette read is immediate (no dummy read)
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        ppu.Write(0x2006, 0x3F);
        ppu.Write(0x2006, 0x00);
        ppu.Write(0x2007, 0x15);

        ppu.Write(0x2006, 0x3F);
        ppu.Write(0x2006, 0x00);
        u8 result = ppu.Read(0x2007);
        Assert.Equal<u8>(0x15, result);
    }

    [Test]
    public static void Test09()
    {
        // # Test 9: OAM write/read
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        ppu.Write(0x2003, 0x00);
        ppu.Write(0x2004, 0xAA);
        ppu.Write(0x2003, 0x00);

        u8 result = ppu.Read(0x2004);
        Assert.Equal<u8>(0xAA, result);

        ppu.Write(0x2003, 0x00);
        ppu.Write(0x2004, 0x11);
        ppu.Write(0x2004, 0x22);
        ppu.Write(0x2003, 0x01);
        result = ppu.Read(0x2004);
        Assert.Equal<u8>(0x22, result);
    }

    [Test]
    public static void Test10()
    {
        // # Test 10: PPUCTRL nametable bits go to t
        Ppu ppu = PreparePpu();
        defer CleanupPpu(ppu);

        ppu.Write(0x2000, 0x03);

        Assert.Equal<u16>(0x0C00, ppu.LoopyRegister.T.Addr & 0x0C00);
        Assert.Equal(3, ppu.LoopyRegister.T.Nametable);
    }
}