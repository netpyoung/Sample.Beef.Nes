using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_BNE
{
    [Test]
    public static void Test3_Bne_BranchTaken()
    {
        // Test 3: BNE — branch taken (Z=0)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x01, // A = $01 (Z=0)
            0xD0, // BNE
            0x02 // offset +2
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$01
        nes.Step(); // BNE +2
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0006);
    }

    [Test]
    public static void Test4_Bne_BackwardBranch()
    {
        // Test 4: BNE — backward branch (negative offset)
        u8[?] bytes = .(
            0xA9, // LDA immediate ($0000)
            0x01, // A = $01
            0xD0, // BNE ($0002)
            0xFC // offset -4 (signed: $FC = -4)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$01
        nes.Step(); // BNE -4
        nes.Debug();

        // PC at $0004 (after BNE operand) + (-4) = $0000
        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0000);
    }

    [Test]
    public static void Test9_CmpBneLoop()
    {
        // Test 9: CMP + BNE loop (count to 3)
        u8[?] bytes = .(
            0xE8, // INX           ($0000)
            0xE0, // CPX immediate ($0001)
            0x03, // compare with $03
            0xD0, // BNE           ($0003)
            0xFB // offset -5 (back to $0000)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        // Loop: INX, CPX, BNE (taken) x2 + INX, CPX, BNE (not taken) x1
        for (int i = 0; i < 9; i++)
        {
            nes.Step();
        }
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.X, 0x03);
    }
}