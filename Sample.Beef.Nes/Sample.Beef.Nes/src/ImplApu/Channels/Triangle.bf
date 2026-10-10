namespace Sample.Beef.Nes.ImplApu.Channels;

class Triangle
{
    u8[?] SEQUENCE = .(
        15, 14, 13, 12, 11, 10, 9, 8,
        7, 6, 5, 4, 3, 2, 1, 0,
        0, 1, 2, 3, 4, 5, 6, 7,
        8, 9, 10, 11, 12, 13, 14, 15
        );

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

    public u8 length_counter { get; private set; }

    bool _control_flag;
    u8 _linear_reload;
    u8 _linear_counter;
    bool _linear_reload_flag;
    u16 _timer;
    u16 _timer_period;
    u8 _sequence_pos;


    public void WriteLinearCounter(u8 val)
    {
        // val: CRRR RRRR
        _control_flag = (val & 0b1000'0000) != 0;
        _linear_reload = (val & 0b0111'1111);
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

        _linear_reload_flag = true;
    }

    public void ClockTimer()
    {
        if (_timer != 0)
        {
            _timer -= 1;
            return;
        }

        _timer = _timer_period;
        if (length_counter > 0 && _linear_counter > 0)
        {
            _sequence_pos = (_sequence_pos + 1) & 0b0001'1111; // 0x1F == 31
        }
    }

    public void ClockLinearCounter()
    {
        if (_linear_reload_flag)
        {
            _linear_counter = _linear_reload;
        }
        else if (_linear_counter > 0)
        {
            _linear_counter -= 1;
        }

        if (!_control_flag)
        {
            _linear_reload_flag = false;
        }
    }

    public void ClockLengthCounter()
    {
        if (!_control_flag && length_counter > 0)
        {
            length_counter -= 1;
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
        if (_linear_counter == 0)
        {
            return 0;
        }
        if (_timer_period < 2)
        {
            return 0;
        }

        return SEQUENCE[_sequence_pos];
    }
}