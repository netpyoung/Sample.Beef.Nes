using System;
using internal Sample.Beef.Nes;

namespace Sample.Beef.Nes.Tests.TestCpu;

public sealed class Test_CLC_SEC_CLI_SEI_CLV_CLD_SED
{
    [Test]
    public static void Test1_SecClc_SetAndClearCarry()
    {
        // Test 1: SEC + CLC — set and clear carry
        u8[?] bytes = .(
            0x38, // SEC
            0x18 // CLC
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        // SEC
        nes.Step();
        nes.Debug();
        Assert.True(nes.Cpu.Register.Status.C);

        // CLC
        nes.Step();
        nes.Debug();
        Assert.False(nes.Cpu.Register.Status.C);
    }

    [Test]
    public static void Test2_Cli_ClearInterruptDisable()
    {
        // Test 2: CLI — clear interrupt disable
        u8[?] bytes = .(
            0x58 // CLI
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        // I starts set (STATUS_INITIAL has I=1)
        nes.Step(); // CLI
        nes.Debug();

        Assert.False(nes.Cpu.Register.Status.I);
    }

    [Test]
    public static void Test3_Sei_SetInterruptDisable()
    {
        // Test 3: CLI + SEI
        u8[?] bytes = .(
            0x58, // CLI
            0x78 // SEI
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // CLI
        nes.Step(); // SEI
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.I);
    }

    [Test]
    public static void Test4_Clv_ClearOverflow()
    {
        // Test 4: CLV — clear overflow
        // Use ADC to set V, then CLV to clear it
        u8[?] bytes = .(
            0xA9, 0x50, // LDA #$50
            0x69, 0x50, // ADC #$50 (overflow: +80 + +80 = -96)
            0xB8 // CLV
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$50
        nes.Step(); // ADC #$50 (sets V=1)
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.V);

        nes.Step(); // CLV
        nes.Debug();

        Assert.False(nes.Cpu.Register.Status.V);
    }

    [Test]
    public static void Test5_SedCld_SetAndClearDecimal()
    {
        // Test 5: SED + CLD — set and clear decimal
        u8[?] bytes = .(
            0xF8, // SED
            0xD8 // CLD
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        // SED
        nes.Step();
        nes.Debug();
        Assert.True(nes.Cpu.Register.Status.D);

        // CLD
        nes.Step();
        nes.Debug();
        Assert.False(nes.Cpu.Register.Status.D);
    }

    [Test]
    public static void Test6_FlagOpsDoNotAffectOtherFlags()
    {
        // Test 6: Flag ops don't affect other flags
        u8[?] bytes = .(
            0xA9, 0x00, // LDA #$00 (sets Z=1)
            0x38 // SEC
            );

        Nes nes = Nes.CreateDummyCartridge();
        defer delete nes;

        nes.LoadBytes(bytes);

        nes.Step(); // LDA #$00 (sets Z=1)
        nes.Step(); // SEC
        nes.Debug();

        Assert.True(nes.Cpu.Register.Status.Z);
        Assert.True(nes.Cpu.Register.Status.C);
    }
}
