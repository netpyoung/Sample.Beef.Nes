using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_ADC
{
    [Test]
    public static void Test_Adc_SimpleAddition()
    {
        // Test 1: ADC — simple addition
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x10, // A = $10
            0x69, // ADC immediate
            0x20 // add $20
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$10
        nes.Step(); // ADC #$20  ; $10 + $20 = $30
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x30);
    }

    [Test]
    public static void Test_Adc_CarryFlag()
    {
        // Test 2: ADC — carry flag (unsigned overflow)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0xFF, // A = $FF
            0x69, // ADC immediate
            0x01 // add $01 ($FF + $01 = $100, wraps to $00)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // ADC #$01  ; $FF + $01 = $00 + C
        nes.Debug();

        bool hasCarry = (nes.Cpu.Register.Status.Value & 0x01) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(hasCarry);
    }

    [Test]
    public static void Test_Adc_ZeroFlag()
    {
        // Test 3: ADC — zero flag
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0xFF, // A = $FF
            0x69, // ADC immediate
            0x01 // add $01 => $00
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // ADC #$01  ; result = $00
        nes.Debug();

        bool isZero = (nes.Cpu.Register.Status.Value & 0x02) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(isZero);
    }

    [Test]
    public static void Test_Adc_NegativeFlag()
    {
        // Test 4: ADC — negative flag
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x50, // A = $50
            0x69, // ADC immediate
            0x40 // add $40 => $90 (bit 7 = 1)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$50
        nes.Step(); // ADC #$40  ; $50 + $40 = $90
        nes.Debug();

        bool isNegative = (nes.Cpu.Register.Status.Value & 0x80) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x90);
        Assert.True(isNegative);
    }

    [Test]
    public static void Test_Adc_Overflow_PositivePositive()
    {
        // Test 5: ADC — overflow (positive + positive = negative)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x50, // A = $50 (+80)
            0x69, // ADC immediate
            0x50 // add $50 (+80) => $A0 (-96 in signed) OVERFLOW!
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$50
        nes.Step(); // ADC #$50  ; +80 + +80 = -96 (overflow!)
        nes.Debug();

        bool isOverflow = (nes.Cpu.Register.Status.Value & 0x40) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.A, 0xA0);
        Assert.True(isOverflow);
    }

    [Test]
    public static void Test_Adc_Overflow_NegativeNegative()
    {
        // Test 6: ADC — overflow (negative + negative = positive)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0xD0, // A = $D0 (-48)
            0x69, // ADC immediate
            0x90 // add $90 (-112) => $D0 + $90 = $160, wraps to $60 (+96) OVERFLOW!
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$D0
        nes.Step(); // ADC #$90  ; -48 + -112 = +96 (overflow!)
        nes.Debug();

        bool isOverflow = (nes.Cpu.Register.Status.Value & 0x40) != 0;
        bool hasCarry = (nes.Cpu.Register.Status.Value & 0x01) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x60);
        Assert.True(isOverflow);
        Assert.True(hasCarry);
    }

    [Test]
    public static void Test_Adc_NoOverflow_PositiveNegative()
    {
        // Test 7: ADC — no overflow (positive + negative)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x50, // A = $50 (+80)
            0x69, // ADC immediate
            0xD0 // add $D0 (-48) => $20 (+32) no overflow
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$50
        nes.Step(); // ADC #$D0  ; +80 + -48 = +32 (no overflow)
        nes.Debug();

        bool isOverflow = (nes.Cpu.Register.Status.Value & 0x40) != 0;

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x20);
        Assert.False(isOverflow);
    }

    [Test]
    public static void Test_Adc_CarryIn()
    {
        // Test 8: ADC — carry in
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0xFF, // A = $FF
            0x69, // ADC immediate
            0x01, // add $01 => sets C=1
            0xA9, // LDA immediate
            0x10, // A = $10
            0x69, // ADC immediate
            0x20 // add $20 + carry = $31
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // ADC #$01  ; sets C=1
        nes.Step(); // LDA #$10
        nes.Step(); // ADC #$20  ; $10 + $20 + C = $31
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x31);
    }


    [Test]
    public static void Test9_Adc_ZeroPage()
    {
        // Test 9: ADC zero page
        u8[?] bytes = .(
            0xA9, 0x10, // LDA #$10
            0x65, 0x20 // ADC $20
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0020, 0x20);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$10
        nes.Step(); // ADC $20
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x30);
    }

    [Test]
    public static void Test10_Adc_Absolute()
    {
        // Test 10: ADC absolute
        u8[?] bytes = .(
            0xA9, 0x10, // LDA #$10
            0x6D, 0x00, 0x02 // ADC $0200
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0200, 0x20);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$10
        nes.Step(); // ADC $0200
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x30);
    }
}
