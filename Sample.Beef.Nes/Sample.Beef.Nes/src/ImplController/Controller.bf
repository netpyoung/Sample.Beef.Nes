namespace Sample.Beef.Nes.ImplController;

class Controller
{
    u8 _buttons;
    u8 _shiftRegister;
    bool _isStrobe;

    public void Press(E_BUTTON button)
    {
        _buttons |= (u8)button;
    }
    public void Release(E_BUTTON button)
    {
        _buttons &= ~(u8)button;
    }

    public void Write(u8 v)
    {
        _isStrobe = (v & 1) != 0;
        if (_isStrobe)
        {
            _shiftRegister = _buttons;
        }
    }

    public bool Read()
    {
        if (_isStrobe)
        {
            return (_buttons & (u8)E_BUTTON.A) != 0;
        }

        bool isOn = (_shiftRegister & 1) != 0;
        _shiftRegister >>= 1;
        return isOn;
    }
}

enum E_BUTTON : u8
{
    A = 0b0000'0001,
    B = 0b0000'0010,
    SELECT = 0b0000'0100,
    START = 0b0000'1000,
    UP = 0b0001'0000,
    DOWN = 0b0010'0000,
    LEFT = 0b0100'0000,
    RIGHT = 0b1000'0000,
}
