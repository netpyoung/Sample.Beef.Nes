using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_INC_DEC_BIT_NOP
{
    [Test]
    public static void Test1_Inc_ZeroPage()
    {
        // Test 1: INC zero page
        u8[?] bytes = .(
            0xE6, 0x10 // INC $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x05);
        nes.LoadBytes(bytes);

        nes.Step(); // INC $10  ; MEM[$10]=$05 + 1 = $06
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);
        Assert.Equal<u8>(result, 0x06);
    }

    [Test]
    public static void Test2_Inc_WrapZeroFlag()
    {
        // Test 2: INC — wrap + zero flag
        u8[?] bytes = .(
            0xE6, 0x10 // INC $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0xFF);
        nes.LoadBytes(bytes);

        nes.Step(); // INC $10  ; MEM[$10]=$FF + 1 = $00
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);

        Assert.Equal<u8>(result, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test3_Inc_NegativeFlag()
    {
        // Test 3: INC — negative flag
        u8[?] bytes = .(
            0xE6, 0x10 // INC $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x7F);
        nes.LoadBytes(bytes);

        nes.Step(); // INC $10  ; MEM[$10]=$7F + 1 = $80
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);

        Assert.Equal<u8>(result, 0x80);
        Assert.True(nes.Cpu.Register.Status.N);
    }

    [Test]
    public static void Test4_Inc_Absolute()
    {
        // Test 4: INC absolute
        u8[?] bytes = .(
            0xEE, 0x00, 0x02 // INC $0200
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0200, 0x05);
        nes.LoadBytes(bytes);

        nes.Step(); // INC $0200
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0200);
        Assert.Equal<u8>(result, 0x06);
    }

    [Test]
    public static void Test5_Dec_ZeroPage()
    {
        // Test 5: DEC zero page
        u8[?] bytes = .(
            0xC6, 0x10 // DEC $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x05);
        nes.LoadBytes(bytes);

        nes.Step(); // DEC $10  ; MEM[$10]=$05 - 1 = $04
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);
        Assert.Equal<u8>(result, 0x04);
    }

    [Test]
    public static void Test6_Dec_ZeroFlag()
    {
        // Test 6: DEC — zero flag
        u8[?] bytes = .(
            0xC6, 0x10 // DEC $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x01);
        nes.LoadBytes(bytes);

        nes.Step(); // DEC $10  ; MEM[$10]=$01 - 1 = $00
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);

        Assert.Equal<u8>(result, 0x00);
        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test7_Dec_WrapNegativeFlag()
    {
        // Test 7: DEC — wrap + negative flag
        u8[?] bytes = .(
            0xC6, 0x10 // DEC $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0x00);
        nes.LoadBytes(bytes);

        nes.Step(); // DEC $10  ; MEM[$10]=$00 - 1 = $FF
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0010);

        Assert.Equal<u8>(result, 0xFF);
        Assert.True(nes.Cpu.Register.Status.N);
    }

    [Test]
    public static void Test8_Dec_Absolute()
    {
        // Test 8: DEC absolute
        u8[?] bytes = .(
            0xCE, 0x00, 0x02 // DEC $0200
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0200, 0x05);
        nes.LoadBytes(bytes);

        nes.Step(); // DEC $0200
        nes.Debug();

        u8 result = nes.CpuBus.Read(0x0200);
        Assert.Equal<u8>(result, 0x04);
    }

    [Test]
    public static void Test9_Bit_ZeroFlag()
    {
        // Test 9: BIT — zero flag (A & MEM == 0)
        u8[?] bytes = .(
            0xA9, 0x0F, // LDA #$0F
            0x24, 0x10 // BIT $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0xF0);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$0F
        nes.Step(); // BIT $10  ; A & MEM[$10] = $0F & $F0 = $00
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test10_Bit_NAndVFromMemory()
    {
        // Test 10: BIT — N and V from memory value
        u8[?] bytes = .(
            0xA9, 0xFF, // LDA #$FF
            0x24, 0x10 // BIT $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0xC0); // bits 7 and 6 set
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$FF
        nes.Step(); // BIT $10  ; MEM[$10]=$C0 (N=1, V=1)
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.N);
        Assert.True(nes.Cpu.Register.Status.V);
        Assert.False(nes.Cpu.Register.Status.Z);
    }

    [Test]
    public static void Test11_Bit_DoesNotModifyA()
    {
        // Test 11: BIT — doesn't modify A
        u8[?] bytes = .(
            0xA9, 0x42, // LDA #$42
            0x24, 0x10 // BIT $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0010, 0xFF);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Step(); // BIT $10
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x42);
    }

    [Test]
    public static void Test12_Bit_Absolute()
    {
        // Test 12: BIT absolute
        u8[?] bytes = .(
            0xA9, 0x0F, // LDA #$0F
            0x2C, 0x00, 0x02 // BIT $0200
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.CpuBus.Write(0x0200, 0xF0);
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$0F
        nes.Step(); // BIT $0200
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.Z);
        Assert.True(nes.Cpu.Register.Status.N);
    }

    [Test]
    public static void Test13_Nop_DoesNothing()
    {
        // Test 13: NOP — does nothing
        u8[?] bytes = .(
            0xA9, 0x42, // LDA #$42
            0xEA // NOP
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        u8 statusBefore = nes.Cpu.Register.Status.Value;
        u8 aBefore = nes.Cpu.Register.A;

        nes.Step(); // NOP
        nes.Debug();

        Assert.Equal(nes.Cpu.Register.A, aBefore);
        Assert.Equal(nes.Cpu.Register.Status.Value, statusBefore);

        u16 expectedOffset = 3;
        Assert.Equal(expectedOffset, nes.Cpu.Register.PC);
    }
}
