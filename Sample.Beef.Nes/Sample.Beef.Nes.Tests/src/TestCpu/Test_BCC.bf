using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_BCC
{
    [Test]
    public static void Test6_Bcc_BranchTaken()
    {
        // Test 6: BCC — branch taken (C=0)
        u8[?] bytes = .(
            0xA9, // LDA immediate
            0x30, // A = $30
            0xC9, // CMP immediate (sets C=0 when A < value)
            0x50, // compare with $50
            0x90, // BCC
            0x02 // offset +2
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$30
        nes.Step(); // CMP #$50  ; C=0
        nes.Step(); // BCC +2
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0008);
    }
}