using System;
using System.IO;

namespace Sample.Beef.Nes.Tests.TestNes;

class Test_Nes
{
    [Test]
    public static void Test1()
    {
        StringView romPath = "TestRoms/nestest/nestest.nes";
        StringView logPath = "TestRoms/nestest/nestest.log";

        Nes nes = Nes.CreateFromPath(romPath);
        defer delete nes;

        nes.Cpu.Register.PC = 0xC000;

        String text = scope String();
        if (File.ReadAllText(logPath, text) case .Err(let err))
        {
            Test.FatalError(scope $"err : {err}");
        }

        int lineNum = 0;
        LINE_LOOP:for (let line in text.Split("\n"))
        {
            u16 expected_pc = .Parse(line[0 ..< 4], .HexNumber).Value;
            u8 expected_a = .Parse(line[50 ..< 52], .HexNumber);
            u8 expected_x = .Parse(line[55 ..< 57], .HexNumber);
            u8 expected_y = .Parse(line[60 ..< 62], .HexNumber);
            u8 expected_status = .Parse(line[65 ..< 67], .HexNumber);
            u8 expected_sp = .Parse(line[71 ..< 73], .HexNumber);

            Assert.Equal(expected_pc, nes.Cpu.Register.PC);
            Assert.Equal(expected_a, nes.Cpu.Register.A);
            Assert.Equal(expected_x, nes.Cpu.Register.X);
            Assert.Equal(expected_y, nes.Cpu.Register.Y);
            Assert.Equal(expected_status, nes.Cpu.Register.Status.Value);
            Assert.Equal(expected_sp, nes.Cpu.Register.SP);

            if (nes.[Friend]Step() case .Err(let nesErr))
            {
                switch (nesErr) {
                case .CpuError(let cpuErr):
                    switch (cpuErr) {
                    case .UnknownOpcode:
                        Assert.Equal(5003, lineNum);
                        break LINE_LOOP;
                    }
                }
            }

            lineNum += 1;
        }
    }
}
