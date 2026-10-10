using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_BPL
{
    [Test]
    public static void Test_Bpl_BranchTaken()
    {
        // Test 8: BPL — branch taken (N=0)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x01, // A = $01 (positive, N=0)
            0x10, // BPL
            0x02 // offset +2
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$01
        nes.Step(); // BPL +2
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0006);
    }
}