using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_JSR_RTS
{
    [Test]
    public static void Test_Jsr_JumpsToTarget()
    {
        // Test 4: JSR — jumps to target
        u8[?] bytes = .(
            0x20, // JSR
            0x05, // low byte
            0x00 // high byte ($0005)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // JSR $0005
        nes.Debug();

        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0005);
    }

    [Test]
    public static void Test_Jsr_PushesReturnAddressToStack()
    {
        // Test 5: JSR — pushes return address to stack
        u8[?] bytes = .(
            0x20, // JSR
            0x05, // low byte
            0x00 // high byte ($0005)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        u8 spBefore = nes.Cpu.Register.SP;

        nes.Step(); // JSR $0005
        nes.Debug();

        // SP should have decreased by 2 (pushed a word)
        Assert.Equal<u8>(nes.Cpu.Register.SP, spBefore - 2);

        // Stack should contain PC-1 = $0002 (last byte of JSR instruction)
        u16 hi = (u16)nes.CpuBus.Read((u16)0x0100 | spBefore);
        u16 lo = (u16)nes.CpuBus.Read((u16)0x0100 | (spBefore - 1));
        u16 returnAddr = (hi << 8) | lo;

        Assert.Equal<u16>(returnAddr, 0x0002);
    }

    [Test]
    public static void Test_JsrRts_RoundTrip()
    {
        // Test 6: JSR + RTS round-trip
        u8[?] bytes = .(
            0x20, // JSR at $0000
            0x05, // low byte
            0x00, // high byte ($0005)
            0xA9, // LDA immediate (at $0003, should execute after RTS)
            0x42, // value
            0x60 // RTS (at $0005, the subroutine)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // JSR $0005
        nes.Debug();

        nes.Step(); // RTS
        nes.Debug();

        // After RTS, PC should be at $0003 (instruction after JSR)
        Assert.Equal<u16>(nes.Cpu.Register.PC, 0x0003);
    }

    [Test]
    public static void Test_JsrRts_ExecutionContinuesCorrectly()
    {
        // Test 7: JSR + RTS — execution continues correctly
        u8[?] bytes = .(
            0x20, // JSR at $0000
            0x05, // low byte
            0x00, // high byte ($0005)
            0xA9, // LDA immediate (at $0003)
            0x42, // value $42
            0x60 // RTS (at $0005)
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // JSR $0005
        nes.Step(); // RTS
        nes.Step(); // LDA #$42
        nes.Debug();

        Assert.Equal<u8>(nes.Cpu.Register.A, 0x42);
    }
}
