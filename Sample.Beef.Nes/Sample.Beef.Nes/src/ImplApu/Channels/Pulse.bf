namespace Sample.Beef.Nes.ImplApu.Channels;

class Pulse
{
    u8[4][8] DUTY_TABLE = .(
        .(0, 1, 0, 0, 0, 0, 0, 0), // # 12.5%
        .(0, 1, 1, 0, 0, 0, 0, 0), // # 25%
        .(0, 1, 1, 1, 1, 0, 0, 0), // # 50%
        .(1, 0, 0, 1, 1, 1, 1, 1) // # 75% (inverted 25%)
        );

    public enum E_CHANNEL
    {
        PULSE_1,
        PULSE_2,
    }

    bool _enabled;
    public bool enabled
    {
        get
        {
            return _enabled;
        }
        set
        {
            _enabled = value;
            if (!_enabled)
            {
                length_counter = 0;
            }
        }
    }

    public u8 length_counter = 0;

    u8 _duty;
    bool _length_halt = false;
    bool _constant_volume = false;
    u8 _volume = 0;
    bool _sweep_enabled = false;
    u8 _sweep_period = 0;
    bool _sweep_negate = false;
    u8 _sweep_shift = 0;
    bool _sweep_reload = false;
    u8 _sweep_divider = 0;
    u16 _timer = 0;
    u16 _timer_period = 0;
    u8 _duty_pos = 0;
    bool _envelope_start = false;
    u8 _envelope_divider = 0;
    u8 _envelope_decay = 0;

    E_CHANNEL _channel;


    public this(E_CHANNEL channel)
    {
        // 0 => pulse1
        // 1 => pulse2
        _channel = channel;
    }

    public void WriteControl(u8 val)
    {
        // val: DDLC VVVV
        _duty = (val & 0b1100'0000) >> 6;
        _length_halt = (val & 0b0010'0000) != 0;
        _constant_volume = (val & 0b0001'0000) != 0;
        _volume = (val & 0b0000'1111);
    }

    public void WriteTimer_lo(u8 val)
    {
        _timer_period &= 0b0000'0111'0000'0000; // 0x0700
        _timer_period |= val;
    }

    public void WriteTimer_hi(u8 val)
    {
        _timer_period &= 0b0000'0000'1111'1111; // 0x00FF

        // val: LLLL LTTT
        _timer_period |= (u16)(val & 0b0000'0111) << 8;
        if (enabled)
        {
            length_counter = ConstChannels.LENGTH_TABLE[(val & 0b1111'1000) >> 3];
        }
        _duty_pos = 0;
        _envelope_start = true;
    }

    public void ClockTimer()
    {
        if (_timer == 0)
        {
            _timer = _timer_period;
            _duty_pos = (_duty_pos + 1) & 0b0000'0111;
        }
        else
        {
            _timer -= 1;
        }
    }

    public u8 Output()
    {
        if (!enabled)
        {
            return 0;
        }

        if (length_counter == 0)
        {
            return 0;
        }

        if (DUTY_TABLE[_duty][_duty_pos] == 0)
        {
            return 0;
        }

        if (_timer_period < 8 || _SweepTargetPeriod() > 0x07FF)
        {
            return 0;
        }

        if (_constant_volume)
        {
            return _volume;
        }

        return _envelope_decay;
    }

    public void ClockEnvelope()
    {
        if (_envelope_start)
        {
            _envelope_start = false;
            _envelope_decay = 15;
            _envelope_divider = _volume;
            return;
        }

        if (_envelope_divider != 0)
        {
            _envelope_divider -= 1;
            return;
        }

        _envelope_divider = _volume;
        if (_envelope_decay > 0)
        {
            _envelope_decay -= 1;
        }
        else if (_length_halt)
        {
            _envelope_decay = 15;
        }
    }

    public void ClockLengthCounter()
    {
        if (!_length_halt && length_counter > 0)
        {
            length_counter -= 1;
        }
    }

    public void WriteSweep(u8 val)
    {
        // val: EPPP NSSS
        _sweep_enabled = (val & 0b1000'0000) != 0;
        _sweep_period = (val & 0b0111'0000) >> 4;
        _sweep_negate = (val & 0b0000'1000) != 0;
        _sweep_shift = (val & 0b0000'0111);
        _sweep_reload = true;
    }

    public void ClockSweep()
    {
        u16 target = _SweepTargetPeriod();

        if (_sweep_enabled && _sweep_divider == 0 && _sweep_shift > 0)
        {
            if (_timer_period >= 8 && target <= 0x07FF)
            {
                _timer_period = target;
            }
        }

        if (_sweep_reload || _sweep_divider == 0)
        {
            _sweep_reload = false;
            _sweep_divider = _sweep_period;
        }
        else
        {
            _sweep_divider -= 1;
        }
    }

    u16 _SweepTargetPeriod()
    {
        int change = _timer_period >> _sweep_shift;
        if (!_sweep_negate)
        {
            return (u16)(_timer_period + change);
        }
        else
        {
            if (_channel == E_CHANNEL.PULSE_1)
            {
                return (u16)(_timer_period - change - 1);
            }

            return _timer_period - 1;
        }
    }
}