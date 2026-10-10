namespace Sample.Beef.Nes.ImplApu.Channels;

class Noise
{
    u16[?] PERIOD_TABLE = .(
        4, 8, 16, 32, 64, 96, 128, 160,
        202, 254, 380, 508, 762, 1016, 2034, 4068
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

    bool _mode = false; // # false = long (32767), true = short (93)
    bool _length_halt = false;
    bool _constant_volume = false;
    u8 _volume = 0;
    u16 _shift_register = 1; // # Loaded with 1 on power-up
    u16 _timer = 0;
    u16 _timer_period = 0;
    bool _envelope_start = false;
    u8 _envelope_divider = 0;
    u8 _envelope_decay = 0;

    public void WriteControl(u8 val)
    {
        // val: --LC VVVV
        _length_halt = (val & 0b0010'0000) != 0;
        _constant_volume = (val & 0b0001'0000) != 0;
        _volume = (val & 0b0000'1111);
    }

    public void WriteModePeriod(u8 val)
    {
        // val: M--- PPPP
        _mode = (val & 0b1000'0000) != 0;
        _timer_period = PERIOD_TABLE[(val & 0b0000'1111)];
    }

    public void WriteLengthCounter(u8 val)
    {
        // val: LLLL L---
        if (enabled)
        {
            length_counter = ConstChannels.LENGTH_TABLE[(val & 0b1111'1000) >> 3];
        }
        _envelope_start = true;
    }

    public void ClockTimer()
    {
        if (_timer != 0)
        {
            _timer -= 1;
            return;
        }

        _timer = _timer_period;
        _Shift();
    }

    public void ClockEnvelope()
    {
        if (_envelope_start)
        {
            _envelope_start = false;
            _envelope_decay = 15;
            _envelope_divider = _volume;
        }
        else
        {
            if (_envelope_divider == 0)
            {
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
            else
            {
                _envelope_divider -= 1;
            }
        }
    }

    public void ClockLengthCounter()
    {
        if (!_length_halt && length_counter > 0)
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
        if ((_shift_register & 1) == 1)
        {
            return 0;
        }

        if (_constant_volume)
        {
            return _volume;
        }
        return _envelope_decay;
    }

    void _Shift()
    {
        int bit;
        if (_mode)
        {
            bit = 6;
        }
        else
        {
            bit = 1;
        }

        u16 feedback = (_shift_register & 1) ^ ((_shift_register >> bit) & 1);
        _shift_register >>= 1;
        _shift_register |= (feedback << 14);
    }
}
