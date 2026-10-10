using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_STA
{
    [Test]
    public static void Test1()
    {
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x42, // 66 // 0b0000_0000
            0x85, // STA zero page
            0x10 // address $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);
        nes.Step(); // LDA
        nes.Step(); // STA
        nes.Debug();

        u8 val = nes.CpuBus.Read(0x10);

        Assert.Equal<u8>(val, 0x42);
    }

    [Test]
    public static void Test2()
    {
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x42, // value
            0xA2, // LDX immediate
            0x05, // X = $05
            0x95, // STA zero page,X
            0x10 // base address $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);
        nes.Step(); // LDA
        nes.Step(); // LDX
        nes.Step(); // STA
        nes.Debug();

        u8 val = nes.CpuBus.Read(0x15);

        Assert.Equal<u8>(val, 0x42);
    }

    [Test]
    public static void Test_Absolute()
    {
        // Test 3: Absolute
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x7F, // value
            0x8D, // STA absolute
            0x00, // low byte of address
            0x02 // high byte ($0200)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$7F
        nes.Step(); // STA $0200
        nes.Debug();

        u8 storedValue = nes.CpuBus.Read(0x0200);
        Assert.Equal<u8>(storedValue, 0x7F);
    }

    [Test]
    public static void Test_AbsoluteX()
    {
        // Test 4: Absolute,X
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x42, // value
            0xA2, // LDX immediate
            0x05, // X = $05
            0x9D, // STA absolute,X
            0x00, // low byte
            0x02 // high byte ($0200)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Step(); // LDX #$05
        nes.Step(); // STA $0200,X
        nes.Debug();

        u8 storedValue = nes.CpuBus.Read(0x0205);
        Assert.Equal<u8>(storedValue, 0x42);
    }

    [Test]
    public static void Test_AbsoluteY()
    {
        // Test 5: Absolute,Y
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x42, // value
            0xA0, // LDY immediate
            0x05, // Y = $05
            0x99, // STA absolute,Y
            0x00, // low byte
            0x02 // high byte ($0200)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Step(); // LDY #$05
        nes.Step(); // STA $0200,Y
        nes.Debug();

        u8 storedValue = nes.CpuBus.Read(0x0205);
        Assert.Equal<u8>(storedValue, 0x42);
    }

    [Test]
    public static void Test_IndirectX()
    {
        // Test 6: Indirect,X (Indexed Indirect)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x42, // value
            0xA2, // LDX immediate
            0x05, // X = $05
            0x81, // STA ($nn,X)
            0x20 // base address $20
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        // Pointer at $25/$26 (base $20 + X $05) points to $0200
        nes.CpuBus.Write(0x25, 0x00); // low byte of pointer
        nes.CpuBus.Write(0x26, 0x02); // high byte of pointer
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Step(); // LDX #$05
        nes.Step(); // STA ($20,X)
        nes.Debug();

        u8 storedValue = nes.CpuBus.Read(0x0200);
        Assert.Equal<u8>(storedValue, 0x42);
    }

    [Test]
    public static void Test_IndirectY()
    {
        // Test 7: Indirect,Y (Indirect Indexed)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x42, // value
            0xA0, // LDY immediate
            0x05, // Y = $05
            0x91, // STA ($nn),Y
            0x20 // base address $20
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        // Pointer at $20/$21 points to $0200, then add Y=$05 => $0205
        nes.CpuBus.Write(0x20, 0x00); // low byte of pointer
        nes.CpuBus.Write(0x21, 0x02); // high byte of pointer
        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$42
        nes.Step(); // LDY #$05
        nes.Step(); // STA ($20),Y
        nes.Debug();

        u8 storedValue = nes.CpuBus.Read(0x0205);
        Assert.Equal<u8>(storedValue, 0x42);
    }

    [Test]
    public static void Test_DoesNotModifyFlags()
    {
        // Test 8: Doesn't modify flags
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x00, // value (sets Z flag)
            0x85, // STA zero page
            0x10 // address
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$00
        nes.Debug();
        u8 statusBefore = nes.Cpu.Register.Status.Value;

        nes.Step(); // STA $10
        nes.Debug();
        u8 statusAfter = nes.Cpu.Register.Status.Value;

        Assert.Equal(statusBefore, statusAfter);
    }
}