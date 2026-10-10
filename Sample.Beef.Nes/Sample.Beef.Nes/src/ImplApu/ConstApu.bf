namespace Sample.Beef.Nes.ImplApu;

public static class ConstApu
{
    public const int SAMPLE_RATE = 44100;
    public const int CPU_CLOCK = 1789773;
    public const float CYCLES_PER_SAMPLE = (float)CPU_CLOCK / SAMPLE_RATE; // # ~40.58

    // # ======= Pulse 1 registers =======
    public readonly static u16 PULSE1_CONTROL_REGISTER = 0x4000; // # DDLC VVVV (duty, length halt, constant vol, volume)
    public readonly static u16 PULSE1_SWEEP_REGISTER = 0x4001; // # EPPP NSSS (enable, period, negate, shift)
    public readonly static u16 PULSE1_TIMER_LOW_REGISTER = 0x4002; // # TTTT TTTT (timer low 8 bits)
    public readonly static u16 PULSE1_TIMER_HIGH_REGISTER = 0x4003; // # LLLL LTTT (length index, timer high 3 bits)

    //# ======= Pulse 2 registers =======
    public readonly static u16 PULSE2_CONTROL_REGISTER = 0x4004;
    public readonly static u16 PULSE2_SWEEP_REGISTER = 0x4005;
    public readonly static u16 PULSE2_TIMER_LOW_REGISTER = 0x4006;
    public readonly static u16 PULSE2_TIMER_HIGH_REGISTER = 0x4007;

    //# ======= Triangle registers =======
    public readonly static u16 TRIANGLE_LINEAR_REGISTER = 0x4008; //# CRRR RRRR (control flag, linear reload)
    public readonly static u16 TRIANGLE_TIMER_LOW_REGISTER = 0x400A;
    public readonly static u16 TRIANGLE_TIMER_HIGH_REGISTER = 0x400B;

    //# ======= Noise registers =======
    public readonly static u16 NOISE_CONTROL_REGISTER = 0x400C; // # --LC VVVV (length halt, constant vol, volume)
    public readonly static u16 NOISE_MODE_PERIOD_REGISTER = 0x400E; // # M--- PPPP (mode, period index)
    public readonly static u16 NOISE_LENGTH_REGISTER = 0x400F; // # LLLL L--- (length index)

    //# ======= Frame counter timing (CPU cycles) =======
    public const int FRAME_STEP_1 = 7457; // # quarter
    public const int FRAME_STEP_2 = 14913; // # quarter + half
    public const int FRAME_STEP_3 = 22371; // # quarter
    public const int FRAME_STEP_4 = 29829; // # quarter + half, mode 0 resets here
    public const int FRAME_STEP_5 = 37281; // # quarter + half, mode 1 resets here

    //# ======= Mixer coefficients (linear approximation) =======
    public const float PULSE_MIX = 0.00752f;
    public const float TND_T_MIX = 0.00851f;
    public const float TND_N_MIX = 0.00494f;
}
