using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_STX
{
    [Test]
    public static void Test_ZeroPage()
    {
        // Test 1: Zero Page
        u8[?] bytes = .(
            0xA2, // LDX immediate
            0x42, // value
            0x86, // STX zero page
            0x10 // address $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDX #$42
        nes.Step(); // STX $10
        nes.Debug();

        u8 storedValue = nes.CpuBus.Read(0x10);
        Assert.Equal<u8>(storedValue, 0x42);
    }

    [Test]
    public static void Test_ZeroPageY()
    {
        // Test 2: Zero Page,Y
        u8[?] bytes = .(
            0xA2, // LDX immediate
            0x42, // value
            0xA0, // LDY immediate
            0x05, // Y = $05
            0x96, // STX zero page,Y
            0x10 // base address $10
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDX #$42
        nes.Step(); // LDY #$05
        nes.Step(); // STX $10,Y  ; => $15
        nes.Debug();

        u8 storedValue = nes.CpuBus.Read(0x15);
        Assert.Equal<u8>(storedValue, 0x42);
    }

    [Test]
    public static void Test_Absolute()
    {
        // Test 3: Absolute
        u8[?] bytes = .(
            0xA2, // LDX immediate
            0x42, // value
            0x8E, // STX absolute
            0x00, // low byte
            0x02 // high byte ($0200)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDX #$42
        nes.Step(); // STX $0200
        nes.Debug();

        u8 storedValue = nes.CpuBus.Read(0x0200);
        Assert.Equal<u8>(storedValue, 0x42);
    }

    [Test]
    public static void Test_DoesNotModifyFlags()
    {
        // Test 4: Doesn't modify flags
        u8[?] bytes = .(
            0xA2, // LDX immediate
            0x00, // value (sets Z flag)
            0x86, // STX zero page
            0x10 // address
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDX #$00
        nes.Debug();
        u8 statusBefore = nes.Cpu.Register.Status.Value;

        nes.Step(); // STX $10
        nes.Debug();
        u8 statusAfter = nes.Cpu.Register.Status.Value;

        Assert.Equal(statusBefore, statusAfter);
    }
}