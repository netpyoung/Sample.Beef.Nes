using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_SBC
{
    [Test]
    public static void Test11_Sbc_SimpleSubtraction()
    {
        // Test 11: SBC — simple subtraction
        u8[?] bytes = .(
            0x38, // SEC (C=1, no borrow)
            0xA9, 0x50, // LDA #$50
            0xE9, 0x10 // SBC #$10 => $50 - $10 = $40
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // LDA #$50
        nes.Step(); // SBC #$10
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x40);
    }

    [Test]
    public static void Test12_Sbc_CarryFlagNoBorrow()
    {
        // Test 12: SBC — carry flag (no borrow)
        u8[?] bytes = .(
            0x38, // SEC
            0xA9, 0x50, // LDA #$50
            0xE9, 0x30 // SBC #$30 => $50 - $30 = $20, C=1 (no borrow)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // LDA #$50
        nes.Step(); // SBC #$30
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x20);
        Assert.True(nes.Cpu.Register.Status.C);
    }

    [Test]
    public static void Test13_Sbc_Borrow()
    {
        // Test 13: SBC — borrow (C=0 when result < 0)
        u8[?] bytes = .(
            0x38, // SEC
            0xA9, 0x30, // LDA #$30
            0xE9, 0x50 // SBC #$50 => $30 - $50 = $E0, C=0 (borrow)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // LDA #$30
        nes.Step(); // SBC #$50
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0xE0);
        Assert.False(nes.Cpu.Register.Status.C);
    }

    [Test]
    public static void Test14_Sbc_ZeroFlag()
    {
        // Test 14: SBC — zero flag
        u8[?] bytes = .(
            0x38, // SEC
            0xA9, 0x42, // LDA #$42
            0xE9, 0x42 // SBC #$42 => $00
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // LDA #$42
        nes.Step(); // SBC #$42
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test15_Sbc_Overflow()
    {
        // Test 15: SBC — overflow (positive - negative = negative)
        u8[?] bytes = .(
            0x38, // SEC
            0xA9, 0x50, // LDA #$50 (+80)
            0xE9, 0xB0 // SBC #$B0 (-80) => +80 - (-80) = +160, wraps to $A0 (-96)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // LDA #$50
        nes.Step(); // SBC #$B0
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0xA0);
        Assert.True(nes.Cpu.Register.Status.V);
    }

    [Test]
    public static void Test16_Sbc_ZeroPage()
    {
        // Test 16: SBC zero page
        u8[?] bytes = .(
            0x38, // SEC
            0xA9, 0x50, // LDA #$50
            0xE5, 0x20 // SBC $20
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0020, 0x10);
        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // LDA #$50
        nes.Step(); // SBC $20
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x40);
    }
}
