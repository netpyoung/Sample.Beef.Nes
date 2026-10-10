using System;
namespace Sample.Beef.Nes.ImplPpu;

struct PpuLoopyRegister
{
    /// <summary>
    /// Current VRAM Address
    /// </summary>
    public PpuVramAddress V;

    /// <summary>
    /// Temporary VRAM Address
    /// </summary>
    public PpuVramAddress T;

    /// <summary>
    /// Fine X Scroll
    /// </summary>
    public u8 FineX;

    /// <summary>
    /// Write Toggle Latch
    /// </summary>
    public bool W;

    public override void ToString(String strBuffer)
    {
        strBuffer.AppendF($"V:{V} T:{T} FineX:{FineX} W:{W}");
    }
}