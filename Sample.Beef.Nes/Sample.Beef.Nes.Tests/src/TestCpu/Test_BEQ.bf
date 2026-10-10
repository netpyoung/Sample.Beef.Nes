using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_BEQ
{
    [Test]
    public static void Test1_Beq_BranchTaken()
    {
        // Test 1: BEQ — branch taken (Z=1)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x00, // A = $00 (sets Z=1)
            0xF0, // BEQ
            0x02 // offset +2 (skip next 2 bytes)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$00
        nes.Step(); // BEQ +2
        nes.Debug();

        // PC should be at $0006 ($0004 + offset $02)
        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0006);
    }

    [Test]
    public static void Test2_Beq_BranchNotTaken()
    {
        // Test 2: BEQ — branch not taken (Z=0)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x01, // A = $01 (Z=0)
            0xF0, // BEQ
            0x02 // offset +2
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$01
        nes.Step(); // BEQ +2
        nes.Debug();

        // PC should be at $0004 (no branch, just past the BEQ instruction)
        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0004);
    }
}