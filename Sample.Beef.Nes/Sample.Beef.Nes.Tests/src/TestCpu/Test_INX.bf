using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_INX
{
    [Test]
    public static void Test1()
    {
        u8[?] bytes = .(
            0xE8 // INX
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);
        nes.Step(); // INX
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.X, 0x01);
    }

    [Test]
    public static void Test2()
    {
        u8[?] bytes = .(
            0xE8, // INX
            0xE8, // INX
            0xE8 // INX
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);
        for (int i = 0; i < 3; ++i)
        {
            nes.Step(); // INX
            nes.Debug();
        }


        Assert.Equal<u8>(nes.Cpu.Register.X, 0x03);
    }

    [Test]
    public static void Test3()
    {
        u8[256] bytes = ?;
        Internal.MemSet(&bytes, 0xE8, bytes.Count); // INX

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);
        for (int i = 0; i < 256; ++i)
        {
            nes.Step(); // INX
            nes.Debug();
        }


        Assert.Equal<u8>(nes.Cpu.Register.X, 0); // 0 ~ 127, -128 ~ 0
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test4()
    {
        u8[128] bytes = ?;
        Internal.MemSet(&bytes, 0xE8, bytes.Count); // INX

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);
        for (int i = 0; i < 128; ++i)
        {
            nes.Step(); // INX
            nes.Debug();
        }


        Assert.Equal<u8>(nes.Cpu.Register.X, 0x80); // -128
        Assert.True(nes.Cpu.Register.Status.N);
    }
}