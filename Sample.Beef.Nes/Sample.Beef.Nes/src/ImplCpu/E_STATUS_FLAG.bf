namespace Sample.Beef.Nes.ImplCpu;

enum E_STATUS_FLAG : u8
{
    // Flag Masks (N V - B D I Z C)

    /// <summary>
    /// 7 - Negative
    /// </summary>
    FLAG_N = 0b1000'0000,

    /// <summary>
    /// 6 - Overflow
    /// </summary>
    FLAG_V = 0b0100'0000,

    /// <summary>
    /// 5 - Unused - always 1
    /// </summary>
    FLAG_U = 0b0010'0000,

    /// <summary>
    /// 4 - Break
    /// </summary>
    FLAG_B = 0b0001'0000,

    /// <summary>
    /// 3 - Decimal
    /// </summary>
    FLAG_D = 0b0000'1000,

    /// <summary>
    /// 2 - Interrupt Disable
    /// </summary>
    FLAG_I = 0b0000'0100,

    /// <summary>
    /// 1 - Zero
    /// </summary>
    FLAG_Z = 0b0000'0010,

    /// <summary>
    /// 0 - Carry
    /// </summary>
    FLAG_C = 0b0000'0001,
}