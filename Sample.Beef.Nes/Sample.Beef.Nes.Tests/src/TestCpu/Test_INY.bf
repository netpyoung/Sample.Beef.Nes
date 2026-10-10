using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_INY
{
    [Test]
    public static void Test1_Iny_SimpleIncrement()
    {
        // Test 1: Simple increment
        u8[?] bytes = .(
            0xC8 // INY
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // INY
        nes.Debug();

        bool isZero = (nes.Cpu.Register.Status.Value & 0x02) != 0;
        bool isNegative = (nes.Cpu.Register.Status.Value & 0x80) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.Y, 1);
        Assert.False(isZero);
        Assert.False(isNegative);
    }

    [Test]
    public static void Test2_Iny_WrapAndZeroFlag()
    {
        // Test 2: Wrap + Zero flag
        u8[256] bytes = ?;
        Internal.MemSet(&bytes, 0xC8, bytes.Count);

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        // INY x255
        for (int i = 0; i < 255; i++)
        {
            nes.Step();
        }
        nes.Debug();

        // INY (wrap)
        nes.Step();
        nes.Debug();

        bool isZero = (nes.Cpu.Register.Status.Value & 0x02) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.Y, 0);
        Assert.True(isZero);
    }

    [Test]
    public static void Test3_Iny_NegativeFlag()
    {
        // Test 3: Negative flag
        u8[128] bytes = ?;
        Internal.MemSet(&bytes, 0xC8, bytes.Count);

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        // INY x128
        for (int i = 0; i < 128; i++)
        {
            nes.Step();
        }
        nes.Debug();

        bool isNegative = (nes.Cpu.Register.Status.Value & 0x80) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.Y, 0x80);
        Assert.True(isNegative);
    }
}