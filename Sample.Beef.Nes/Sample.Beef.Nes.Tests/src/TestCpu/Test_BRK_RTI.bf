using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_BRK_RTI
{
    [Test]
    public static void Test1_Brk_PushesPcPlus1ToStack()
    {
        // Test 1: BRK — pushes PC+1 to stack
        u8[?] bytes = .(
            0x00, // BRK at $0000
            0x00 // padding byte (signature)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        u8 spBefore = nes.Cpu.Register.SP;

        nes.Step(); // BRK
        nes.Debug();

        // SP should decrease by 3 (2 for PC word + 1 for status byte)
        u8 expectedSp = (u8)(spBefore - 3);
        Assert.Equal(nes.Cpu.Register.SP, expectedSp);
    }

    [Test]
    public static void Test2_Brk_ReturnAddressOnStackIsPcPlus1()
    {
        // Test 2: BRK — return address on stack is PC+1
        u8[?] bytes = .(
            0x00, // BRK at $0000
            0x00 // padding byte
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        u8 spBefore = nes.Cpu.Register.SP;

        nes.Step(); // BRK

        // Stack should contain return address $0002 (PC was $0001 after fetch, +1 = $0002)
        u16 hiAddress = 0x0100 | (u16)spBefore;
        u16 loAddress = 0x0100 | (u16)(spBefore - 1);

        u16 hi = (u16)nes.CpuBus.Read(hiAddress);
        u16 lo = (u16)nes.CpuBus.Read(loAddress);
        u16 returnAddr = (hi << 8) | lo;

        Assert.Equal<u16>(returnAddr, 0x0002);
    }

    [Test]
    public static void Test3_Brk_PushesStatusWithBandUSet()
    {
        // Test 3: BRK — pushes status with B and U set
        u8[?] bytes = .(
            0x00, // BRK
            0x00 // padding
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        u8 spBefore = nes.Cpu.Register.SP;

        nes.Step(); // BRK

        // Status byte is pushed third (after the 2-byte address)
        u16 statusAddress = 0x0100 | ((u16)spBefore - 2);
        u8 pushedStatus = nes.CpuBus.Read(statusAddress);

        // B (bit 4: 0x10) and U (bit 5: 0x20) should be set in the pushed copy
        bool bSet = (pushedStatus & 0x10) != 0;
        bool uSet = (pushedStatus & 0x20) != 0;

        Assert.True(bSet);
        Assert.True(uSet);
    }

    [Test]
    public static void Test4_Brk_SetsIFlag()
    {
        // Test 4: BRK — sets I flag
        u8[?] bytes = .(
            0x00, // BRK
            0x00 // padding
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // BRK
        nes.Debug();

        // I flag (bit 2: 0x04) should be set
        bool iFlag = (nes.Cpu.Register.Status.Value & 0x04) != 0;

        Assert.True(iFlag);
    }

    [Test]
    public static void Test5_Brk_JumpsToIrqVectorAddress()
    {
        // Test 5: BRK — jumps to IRQ vector address
        // Without cartridge, bus returns $00 for $FFFE/$FFFF, so PC = $0000
        u8[?] bytes = .(
            0x00, // BRK
            0x00 // padding
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // BRK
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0000);
    }

    [Test]
    public static void Test6_BrkRti_RoundTrip()
    {
        // Test 6: BRK + RTI round-trip
        u8[?] bytes = .(
            0x00, // BRK at $0000
            0x00, // padding byte
            0xA9, // LDA immediate at $0002 (should execute after RTI returns here)
            0x42 // value $42
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // BRK

        // BRK jumped to $0000 (no cartridge). Overwrite $0000 with RTI so we can return.
        nes.CpuBus.Write(0x0000, 0x40); // RTI opcode

        nes.Step(); // RTI
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0002);
    }

    [Test]
    public static void Test7_BrkRti_ExecutionContinuesAfterBrk()
    {
        // Test 7: BRK + RTI — execution continues after BRK
        u8[?] bytes = .(
            0x00, // BRK at $0000
            0x00, // padding byte
            0xA9, // LDA immediate at $0002
            0x42 // value $42
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // BRK

        nes.CpuBus.Write(0x0000, 0x40); // RTI opcode

        nes.Step(); // RTI
        nes.Step(); // LDA #$42
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x42);
    }

    [Test]
    public static void Test8_Rti_RestoresStatusFlags()
    {
        // Test 8: RTI — restores status flags
        u8[?] bytes = .(
            0x00, // BRK at $0000
            0x00 // padding byte
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // BRK

        nes.CpuBus.Write(0x0000, 0x40); // RTI opcode

        nes.Step(); // RTI
        nes.Debug();

        // RTI restores status but clears B and forces U
        u8 statusAfter = nes.Cpu.Register.Status.Value;

        bool bClear = (statusAfter & 0x10) == 0;
        bool uSet = (statusAfter & 0x20) != 0;

        Assert.True(bClear);
        Assert.True(uSet);
    }
}
