using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_JMP
{
    [Test]
    public static void Test_JmpAbsolute()
    {
        // Test 1: JMP absolute
        u8[?] bytes = .(
            0x4C, // JMP absolute
            0x05, // low byte
            0x00 // high byte ($0005)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // JMP $0005
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0005);
    }

    [Test]
    public static void Test_JmpIndirect()
    {
        // Test 2: JMP indirect
        u8[?] bytes = .(
            0x6C, // JMP indirect
            0x10, // low byte of pointer
            0x00 // high byte of pointer ($0010)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        // Pointer at $0010/$0011 contains target $0200
        nes.CpuBus.Write(0x0010, 0x00);
        nes.CpuBus.Write(0x0011, 0x02);
        nes.LoadBytes(bytes);

        nes.Step(); // JMP ($0010)  ; ptr => $0200
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0200);
    }

    [Test]
    public static void Test_JmpIndirect_PageBoundaryBug()
    {
        // Test 3: JMP indirect — page boundary bug
        u8[?] bytes = .(
            0x6C, // JMP indirect
            0xFF, // low byte of pointer
            0x02 // high byte of pointer ($02FF)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        // Pointer at $02FF/$0300 — but 6502 reads $02FF and $0200 (page wrap bug)
        nes.CpuBus.Write(0x02FF, 0x40); // low byte of target
        nes.CpuBus.Write(0x0200, 0x80); // high byte (buggy read from $0200, not $0300)
        nes.CpuBus.Write(0x0300, 0xFF); // would be correct high byte, but 6502 ignores this
        nes.LoadBytes(bytes);

        nes.Step(); // JMP ($02FF)  ; buggy: reads $02FF and $0200
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x8040);
    }
}
