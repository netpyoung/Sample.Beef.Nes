using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_AND_ORA_EOR
{
    [Test]
    public static void Test1_And_Immediate()
    {
        // Test 1: AND immediate
        u8[?] bytes = .(
            0xA9, 0xFF, // LDA #$FF
            0x29, 0x0F // AND #$0F
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // AND #$0F
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x0F);
    }

    [Test]
    public static void Test2_And_ZeroFlag()
    {
        // Test 2: AND — zero flag
        u8[?] bytes = .(
            0xA9, 0xF0, // LDA #$F0
            0x29, 0x0F // AND #$0F
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$F0
        nes.Step(); // AND #$0F
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test3_And_NegativeFlag()
    {
        // Test 3: AND — negative flag
        u8[?] bytes = .(
            0xA9, 0xFF, // LDA #$FF
            0x29, 0x80 // AND #$80
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // AND #$80
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x80);
        Assert.True(nes.Cpu.Register.Status.N);
    }

    [Test]
    public static void Test4_And_ZeroPage()
    {
        // Test 4: AND zero page
        u8[?] bytes = .(
            0xA9, 0xFF, // LDA #$FF
            0x25, 0x10 // AND $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x0F);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // AND $10
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x0F);
    }

    [Test]
    public static void Test5_And_Absolute()
    {
        // Test 5: AND absolute
        u8[?] bytes = .(
            0xA9, 0xFF, // LDA #$FF
            0x2D, 0x00, 0x02 // AND $0200
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0200, 0x0F);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // AND $0200
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x0F);
    }

    [Test]
    public static void Test6_Ora_Immediate()
    {
        // Test 6: ORA immediate
        u8[?] bytes = .(
            0xA9, 0xF0, // LDA #$F0
            0x09, 0x0F // ORA #$0F
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$F0
        nes.Step(); // ORA #$0F
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0xFF);
    }

    [Test]
    public static void Test7_Ora_ZeroFlag()
    {
        // Test 7: ORA — zero flag
        u8[?] bytes = .(
            0xA9, 0x00, // LDA #$00
            0x09, 0x00 // ORA #$00
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$00
        nes.Step(); // ORA #$00
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test8_Ora_ZeroPage()
    {
        // Test 8: ORA zero page
        u8[?] bytes = .(
            0xA9, 0xF0, // LDA #$F0
            0x05, 0x10 // ORA $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x0F);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$F0
        nes.Step(); // ORA $10
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0xFF);
    }

    [Test]
    public static void Test9_Eor_Immediate()
    {
        // Test 9: EOR immediate
        u8[?] bytes = .(
            0xA9, 0xFF, // LDA #$FF
            0x49, 0x0F // EOR #$0F
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // EOR #$0F
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0xF0);
    }

    [Test]
    public static void Test10_Eor_ZeroFlag()
    {
        // Test 10: EOR — zero flag (XOR with itself)
        u8[?] bytes = .(
            0xA9, 0x42, // LDA #$42
            0x49, 0x42 // EOR #$42
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Step(); // EOR #$42
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test11_Eor_ZeroPage()
    {
        // Test 11: EOR zero page
        u8[?] bytes = .(
            0xA9, 0xFF, // LDA #$FF
            0x45, 0x10 // EOR $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0xF0);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // EOR $10
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x0F);
    }
}
