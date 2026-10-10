using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_DEY
{
    [Test]
    public static void Test1_Dey_SimpleDecrement()
    {
        // Test 1: Simple decrement
        u8[?] bytes = .(
            0xA0, 0x05, // LDY #$05
            0x88 // DEY
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDY #$05
        nes.Step(); // DEY
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.Y, 0x04);
    }

    [Test]
    public static void Test2_Dey_ZeroFlag()
    {
        // Test 2: Zero flag
        u8[?] bytes = .(
            0xA0, 0x01, // LDY #$01
            0x88 // DEY
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDY #$01
        nes.Step(); // DEY
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.Y, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test3_Dey_WrapAndNegativeFlag()
    {
        // Test 3: Wrap + Negative flag
        u8[?] bytes = .(
            0x88 // DEY (Y starts at $00, wraps to $FF)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // DEY (Y=$00 wraps to $FF)
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.Y, 0xFF);
        Assert.True(nes.Cpu.Register.Status.N);
    }
}
