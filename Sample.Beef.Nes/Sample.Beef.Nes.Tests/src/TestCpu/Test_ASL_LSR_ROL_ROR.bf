using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_ASL_LSR_ROL_ROR
{
    [Test]
    public static void Test1_Asl_AccumulatorBasicShift()
    {
        // Test 1: ASL accumulator — basic shift
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x05, // A = $05 (0000_0101)
            0x0A // ASL accumulator
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$05
        nes.Step(); // ASL A  ; $05 << 1 = $0A
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x0A);
    }

    [Test]
    public static void Test2_Asl_CarryFlag()
    {
        // Test 2: ASL — carry flag (bit 7 shifts out)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x80, // A = $80 (1000_0000)
            0x0A // ASL accumulator
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$80
        nes.Step(); // ASL A  ; bit 7 was 1, shifts to C
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.C);
    }

    [Test]
    public static void Test3_Asl_ZeroFlag()
    {
        // Test 3: ASL — zero flag
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x80, // A = $80 (1000_0000)
            0x0A // ASL accumulator => $00
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$80
        nes.Step(); // ASL A  ; $80 << 1 = $00
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test4_Asl_NegativeFlag()
    {
        // Test 4: ASL — negative flag
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x40, // A = $40 (0100_0000)
            0x0A // ASL accumulator => $80
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$40
        nes.Step(); // ASL A  ; $40 << 1 = $80
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x80);
        Assert.True(nes.Cpu.Register.Status.N);
    }

    [Test]
    public static void Test5_Asl_NoCarry()
    {
        // Test 5: ASL — no carry (bit 7 was 0)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x01, // A = $01 (0000_0001)
            0x0A // ASL accumulator => $02
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$01
        nes.Step(); // ASL A  ; bit 7 was 0, C=0
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x02);
        Assert.False(nes.Cpu.Register.Status.C);
    }

    [Test]
    public static void Test6_Asl_ZeroPage()
    {
        // Test 6: ASL zero page — read-modify-write
        u8[?] bytes = .(
            0x06, 0x10 // ASL $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x05);
        nes.LoadBytes(bytes);

        nes.Step(); // ASL $10  ; MEM[$10]=$05 << 1 = $0A
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);
        Assert.Equal<u8>(result, 0x0A);
    }

    [Test]
    public static void Test7_Lsr_Accumulator()
    {
        // Test 7: LSR accumulator
        u8[?] bytes = .(
            0xA9, 0x04, // LDA #$04
            0x4A // LSR A => $02
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$04
        nes.Step(); // LSR A
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x02);
    }

    [Test]
    public static void Test8_Lsr_CarryFlag()
    {
        // Test 8: LSR — carry flag (bit 0 shifts out)
        u8[?] bytes = .(
            0xA9, 0x01, // LDA #$01
            0x4A // LSR A => $00, C=1
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$01
        nes.Step(); // LSR A
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.C);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test9_Lsr_NAlwaysZero()
    {
        // Test 9: LSR — N always 0 (bit 7 is always 0 after right shift)
        u8[?] bytes = .(
            0xA9, 0xFF, // LDA #$FF
            0x4A // LSR A => $7F
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // LSR A
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x7F);
        Assert.False(nes.Cpu.Register.Status.N);
    }

    [Test]
    public static void Test10_Lsr_ZeroPage()
    {
        // Test 10: LSR zero page
        u8[?] bytes = .(
            0x46, 0x10 // LSR $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x04);
        nes.LoadBytes(bytes);

        nes.Step(); // LSR $10
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);
        Assert.Equal<u8>(result, 0x02);
    }

    [Test]
    public static void Test11_Rol_Accumulator()
    {
        // Test 11: ROL accumulator — rotates carry in
        u8[?] bytes = .(
            0x38, // SEC (C=1)
            0xA9, 0x00, // LDA #$00
            0x2A // ROL A => $01 (carry rotates into bit 0)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // LDA #$00
        nes.Step(); // ROL A
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x01);
    }

    [Test]
    public static void Test12_Rol_Bit7GoesToCarry()
    {
        // Test 12: ROL — bit 7 goes to carry
        u8[?] bytes = .(
            0xA9, 0x80, // LDA #$80
            0x2A // ROL A => $00, C=1
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$80
        nes.Step(); // ROL A
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.C);
    }

    [Test]
    public static void Test13_Rol_ZeroPage()
    {
        // Test 13: ROL zero page
        u8[?] bytes = .(
            0x38, // SEC
            0x26, 0x10 // ROL $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x00);
        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // ROL $10
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);
        Assert.Equal<u8>(result, 0x01);
    }

    [Test]
    public static void Test14_Ror_Accumulator()
    {
        // Test 14: ROR accumulator — rotates carry in
        u8[?] bytes = .(
            0x38, // SEC (C=1)
            0xA9, 0x00, // LDA #$00
            0x6A // ROR A => $80 (carry rotates into bit 7)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // LDA #$00
        nes.Step(); // ROR A
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x80);
    }

    [Test]
    public static void Test15_Ror_Bit0GoesToCarry()
    {
        // Test 15: ROR — bit 0 goes to carry
        u8[?] bytes = .(
            0xA9, 0x01, // LDA #$01
            0x6A // ROR A => $00, C=1
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$01
        nes.Step(); // ROR A
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x00);
        Assert.True(nes.Cpu.Register.Status.C);
    }

    [Test]
    public static void Test16_Ror_ZeroPage()
    {
        // Test 16: ROR zero page
        u8[?] bytes = .(
            0x38, // SEC
            0x66, 0x10 // ROR $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x00);
        nes.LoadBytes(bytes);

        nes.Step(); // SEC
        nes.Step(); // ROR $10
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);
        Assert.Equal<u8>(result, 0x80);
    }
}
