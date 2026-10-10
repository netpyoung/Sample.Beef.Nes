using System;
using System.Diagnostics;
using Sample.Beef.Nes.ImplCpu;
using Sample.Beef.Nes.ImplCartridge;
using Sample.Beef.Nes.ImplPpu;
using Sample.Beef.Nes.ImplApu;

namespace Sample.Beef.Nes;

typealias u8 = uint8;
typealias u16 = uint16;
typealias u32 = uint32;

typealias i8 = int8;
typealias i16 = int16;
typealias i32 = int32;

static
{
    public static bool IsFlagOn(this uint8 x, E_STATUS_FLAG flag)
    {
        return (x & (uint8)flag) != 0;
    }
}

public class Nes
{
    public Cpu Cpu { get; } = null ~ delete _;

    public CpuBus CpuBus { get; } = null ~ delete _;
    public Apu Apu { get; } = null ~ delete _;
    public Ppu Ppu { get; } = null ~ delete _;
    public PpuBus PpuBus { get; } = null ~ delete _;

    public Cartridge Cartridge { get; } = null ~ delete _;

    public u8* FrameBufferPtr => Ppu.FrameBufferPtr;


    public static Nes CreateDummyCartridge()
    {
        Cartridge cartridge = Cartridge.CreateDummyCartridge();
        return new Nes(cartridge);
    }

    public static Nes CreateFromPath(StringView romPath)
    {
        Cartridge cartridge = Cartridge.CreateFromPath(romPath);
        return new Nes(cartridge);
    }

    public this(Cartridge cartridge)
    {
        Cartridge = cartridge;

        PpuBus = new PpuBus(Cartridge);
        Ppu = new Ppu(PpuBus);

        Apu = new Apu();

        CpuBus = new CpuBus(Cartridge, Ppu, Apu);
        Cpu = new Cpu(CpuBus);

        Cpu.Reset();
    }

    public void RunFrame()
    {
        if (Ppu.IsFrameReady)
        {
            Ppu.ClearFrameReady();
        }

        while (!Ppu.IsFrameReady)
        {
            Step();
        }
    }

    // TODO(pyoung): loadbytes => loadu8
    public void LoadBytes(Span<uint8> data)
    {
        for (u16 i = 0; i < data.Length; ++i)
        {
            CpuBus.Write(i, data[i]);
        }
    }

    public enum NesError
    {
        case CpuError(Cpu.CpuError);
    }

    internal Result<int, NesError> Step()
    {
        if (Cpu.Step(let cpuCycle) case .Err(let err))
        {
            return .Err(.CpuError(err));
        }

        for (int i = 0; i < cpuCycle * 3; ++i)
        {
            Ppu.Step(let isNmiTriggerRequired);
            if (isNmiTriggerRequired)
            {
                Cpu.Nmi();
            }
        }

        for (int i = 0; i < cpuCycle; ++i)
        {
            Apu.Step();
        }

        return .Ok(cpuCycle);
    }

    public void Debug()
    {
        Console.WriteLine(Cpu);
    }
}
