using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_DEX
{
    [Test]
    public static void Test1_Dex_SimpleDecrement()
    {
        // Test 1: Simple decrement
        u8[?] bytes = .(
            0xA2, 0x05, // LDX #$05
            0xCA // DEX
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDX #$05
        nes.Step(); // DEX
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.X, 0x04);
    }

    [Test]
    public static void Test2_Dex_ZeroFlag()
    {
        // Test 2: Zero flag
        u8[?] bytes = .(
            0xA2, 0x01, // LDX #$01
            0xCA // DEX
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDX #$01
        nes.Step(); // DEX
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.X, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test3_Dex_WrapAndNegativeFlag()
    {
        // Test 3: Wrap + Negative flag
        u8[?] bytes = .(
            0xCA // DEX (X starts at $00, wraps to $FF)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // DEX (X=$00 wraps to $FF)
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.X, 0xFF);
        Assert.True(nes.Cpu.Register.Status.N);
    }
}
