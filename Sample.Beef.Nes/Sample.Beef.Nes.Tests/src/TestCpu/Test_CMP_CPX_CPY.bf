using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_CMP_CPX_CPY
{
    [Test]
    public static void Test1_Cmp_AGreaterThanValue()
    {
        // Test 1: CMP — A > value (C=1, Z=0)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x50, // A = $50
            0xC9, // CMP immediate
            0x30 // compare with $30
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$50
        nes.Step(); // CMP #$30
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.C);
        Assert.False(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test2_Cmp_AEqualsValue()
    {
        // Test 2: CMP — A == value (C=1, Z=1)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x42, // A = $42
            0xC9, // CMP immediate
            0x42 // compare with $42
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Debug();
        nes.Step(); // CMP #$42
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.C);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test3_Cmp_ALessThanValue()
    {
        // Test 3: CMP — A < value (C=0, Z=0)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x30, // A = $30
            0xC9, // CMP immediate
            0x50 // compare with $50
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$30
        nes.Step(); // CMP #$50
        nes.Debug();

        Assert.False(nes.Cpu.Register.Status.C);
        Assert.False(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test4_Cmp_NegativeFlag()
    {
        // Test 4: CMP — negative flag
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x30, // A = $30
            0xC9, // CMP immediate
            0x50 // compare with $50 ($30 - $50 = $E0, bit 7 = 1)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$30
        nes.Step(); // CMP #$50
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.N);
    }

    [Test]
    public static void Test5_Cmp_DoesNotModifyA()
    {
        // Test 5: CMP — doesn't modify A
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x42, // A = $42
            0xC9, // CMP immediate
            0x30 // compare with $30
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Step(); // CMP #$30
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x42);
    }

    [Test]
    public static void Test6_Cpx_XGreaterThanValue()
    {
        // Test 6: CPX — X > value
        u8[?] bytes = .(
            0xA2, // LDX immediate
            0x50, // X = $50
            0xE0, // CPX immediate
            0x30 // compare with $30
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDX #$50
        nes.Step(); // CPX #$30
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.C);
        Assert.False(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test7_Cpy_YEqualsValue()
    {
        // Test 7: CPY — Y == value
        u8[?] bytes = .(
            0xA0, // LDY immediate
            0x42, // Y = $42
            0xC0, // CPY immediate
            0x42 // compare with $42
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDY #$42
        nes.Step(); // CPY #$42
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.C);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test8_Cmp_ZeroPage()
    {
        // Test 8: CMP zero page
        u8[?] bytes = .(
            0xA9, 0x50, // LDA #$50
            0xC5, 0x10 // CMP $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x30);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$50
        nes.Step(); // CMP $10
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.C);
        Assert.False(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test9_Cmp_Absolute()
    {
        // Test 9: CMP absolute
        u8[?] bytes = .(
            0xA9, 0x42, // LDA #$42
            0xCD, 0x00, 0x02 // CMP $0200
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0200, 0x42);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Step(); // CMP $0200
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.C);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test10_Cpx_ZeroPage()
    {
        // Test 10: CPX zero page
        u8[?] bytes = .(
            0xA2, 0x50, // LDX #$50
            0xE4, 0x10 // CPX $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x30);
        nes.LoadBytes(bytes);

        nes.Step(); // LDX #$50
        nes.Step(); // CPX $10
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.C);
        Assert.False(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test11_Cpy_Absolute()
    {
        // Test 11: CPY absolute
        u8[?] bytes = .(
            0xA0, 0x42, // LDY #$42
            0xCC, 0x00, 0x02 // CPY $0200
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0200, 0x42);
        nes.LoadBytes(bytes);

        nes.Step(); // LDY #$42
        nes.Step(); // CPY $0200
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.C);
        Assert.True(nes.Cpu.Register.Status.Z);
    }
}
