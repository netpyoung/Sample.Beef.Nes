using System;
using Sample.Beef.Nes.ImplApu.Channels;
using System.Collections;
namespace Sample.Beef.Nes.ImplApu;

class Apu
{
    Pulse _pulse1 = new Pulse(Pulse.E_CHANNEL.PULSE_1) ~ delete _;
    Pulse _pulse2 = new Pulse(Pulse.E_CHANNEL.PULSE_2) ~ delete _;

    Triangle _triangle = new Triangle() ~ delete _;
    Noise _noise = new Noise() ~ delete _;

    List<float> _sampleBuffer = new List<float>(capacity: 800) ~ delete _;

    u8 _frame_mode;
    int _frame_cycle;
    float _sample_clock;
    uint _cycle;

    public void Step()
    {
        _triangle.ClockTimer();

        if (_cycle % 2 == 0)
        {
            _pulse1.ClockTimer();
            _pulse2.ClockTimer();
            _noise.ClockTimer();
        }

        _ClockFrameCounter();

        _sample_clock += 1.0f;

        if (_sample_clock >= ConstApu.CYCLES_PER_SAMPLE)
        {
            _sample_clock -= ConstApu.CYCLES_PER_SAMPLE;
            _TakeSample();
        }

        _cycle += 1;
    }

    private void _TakeSample()
    {
        float p1 = (float)_pulse1.Output();
        float p2 = (float)_pulse2.Output();
        float t = (float)_triangle.Output();
        float n = (float)_noise.Output();

        float pulse_out = ConstApu.PULSE_MIX * (p1 + p2);
        float tnd_out = ConstApu.TND_T_MIX * t + ConstApu.TND_N_MIX * n;

        float sample = (pulse_out + tnd_out);
        _sampleBuffer.Add(sample);
    }

    private void _ClockFrameCounter()
    {
        _frame_cycle += 1;

        bool quarter = false;
        bool half = false;

        if (_frame_mode == 0)
        {
            switch (_frame_cycle)
            {
            case ConstApu.FRAME_STEP_1:
                quarter = true;
                break;
            case ConstApu.FRAME_STEP_2:
                quarter = true;
                half = true;
                break;
            case ConstApu.FRAME_STEP_3:
                quarter = true;
                break;
            case ConstApu.FRAME_STEP_4:
                quarter = true;
                half = true;
                _frame_cycle = 0;
                break;
            default:
                break;
            }
        }
        else
        {
            switch (_frame_cycle)
            {
            case ConstApu.FRAME_STEP_1:
                quarter = true;
                break;
            case ConstApu.FRAME_STEP_2:
                quarter = true;
                half = true;
                break;
            case ConstApu.FRAME_STEP_3:
                quarter = true;
                break;
            case ConstApu.FRAME_STEP_4:
                quarter = true;
                half = true;
                _frame_cycle = 0;
                break;
            default:
                break;
            }
        }

        if (quarter)
        {
            clock_quarter_frame();
        }
        if (half)
        {
            clock_half_frame();
        }
    }

    public void Write(u16 addr, u8 value)
    {
        if (addr == ConstApu.PULSE1_CONTROL_REGISTER)
        {
            _pulse1.WriteControl(value);
            return;
        }

        if (addr == ConstApu.PULSE1_SWEEP_REGISTER)
        {
            _pulse1.WriteSweep(value);
            return;
        }

        if (addr == ConstApu.PULSE1_TIMER_LOW_REGISTER)
        {
            _pulse1.WriteTimer_lo(value);
            return;
        }

        if (addr == ConstApu.PULSE1_TIMER_HIGH_REGISTER)
        {
            _pulse1.WriteTimer_hi(value);
            return;
        }

        if (addr == ConstApu.PULSE2_CONTROL_REGISTER)
        {
            _pulse2.WriteControl(value);
            return;
        }

        if (addr == ConstApu.PULSE2_SWEEP_REGISTER)
        {
            _pulse2.WriteSweep(value);
            return;
        }

        if (addr == ConstApu.PULSE2_TIMER_LOW_REGISTER)
        {
            _pulse2.WriteTimer_lo(value);
            return;
        }

        if (addr == ConstApu.PULSE2_TIMER_HIGH_REGISTER)
        {
            _pulse2.WriteTimer_hi(value);
            return;
        }

        if (addr == ConstApu.TRIANGLE_LINEAR_REGISTER)
        {
            _triangle.WriteLinearCounter(value);
            return;
        }
        if (addr == ConstApu.TRIANGLE_TIMER_LOW_REGISTER)
        {
            _triangle.WriteTimer_lo(value);
            return;
        }
        if (addr == ConstApu.TRIANGLE_TIMER_HIGH_REGISTER)
        {
            _triangle.WriteTimer_hi(value);
            return;
        }

        if (addr == ConstApu.NOISE_CONTROL_REGISTER)
        {
            _noise.WriteControl(value);
            return;
        }
        if (addr == ConstApu.NOISE_MODE_PERIOD_REGISTER)
        {
            _noise.WriteModePeriod(value);
            return;
        }
        if (addr == ConstApu.NOISE_LENGTH_REGISTER)
        {
            _noise.WriteLengthCounter(value);
            return;
        }
    }

    public void WriteStatus(u8 value)
    {
        _pulse1.enabled = (value & (u8)E_CHANNEL_STATUS.STATUS_PULSE1) != 0;
        _pulse2.enabled = (value & (u8)E_CHANNEL_STATUS.STATUS_PULSE2) != 0;
        _triangle.enabled = (value & (u8)E_CHANNEL_STATUS.STATUS_TRIANGLE) != 0;
        _noise.enabled = (value & (u8)E_CHANNEL_STATUS.STATUS_NOISE) != 0;
    }

    public u8 ReadStatus()
    {
        u8 ret = 0;
        if (_pulse1.length_counter > 0)
        {
            ret |= (u8)E_CHANNEL_STATUS.STATUS_PULSE1;
        }
        if (_pulse2.length_counter > 0)
        {
            ret |= (u8)E_CHANNEL_STATUS.STATUS_PULSE2;
        }
        if (_triangle.length_counter > 0)
        {
            ret |= (u8)E_CHANNEL_STATUS.STATUS_TRIANGLE;
        }
        if (_noise.length_counter > 0)
        {
            ret |= (u8)E_CHANNEL_STATUS.STATUS_NOISE;
        }
        return ret;
    }


    public void WriteFrameCounter(u8 val)
    {
        _frame_mode = (val & 0b1000'0000) >> 7;
        _frame_cycle = 0;

        if (_frame_mode == 1)
        {
            clock_quarter_frame();
            clock_half_frame();
        }
    }


    public void FillSampleNonAlloc(Span<float> output, out int outLen)
    {
        // TODO(pyoung): return span instead of outLen
        int available = _sampleBuffer.Count;
        int copyCount = Math.Min(available, output.Length);
        if (copyCount == 0)
        {
            outLen = 0;
            return;
        }

        _sampleBuffer.CopyTo(0, output, 0, copyCount);
        _sampleBuffer.RemoveRange(0, copyCount);
        outLen = copyCount;
    }


    void clock_quarter_frame()
    {
        _pulse1.ClockEnvelope();
        _pulse2.ClockEnvelope();
        _triangle.ClockLinearCounter();
        _noise.ClockEnvelope();
    }

    void clock_half_frame()
    {
        _pulse1.ClockLengthCounter();
        _pulse1.ClockSweep();
        _pulse2.ClockLengthCounter();
        _pulse2.ClockSweep();
        _triangle.ClockLengthCounter();
        _noise.ClockLengthCounter();
    }
}