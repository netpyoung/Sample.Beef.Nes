using System;
namespace Sample.Beef.Nes.ImplCpu;

struct StatusRegister
{
    u8 _flags;

    public u8 Value => _flags;

    public this(E_STATUS_FLAG flag)
    {
        _flags = (u8)flag;
    }

    public void Reset(u8 v) mut
    {
        _flags = v;
    }

    /// <summary>
    /// Negative
    /// </summary>
    public bool N
    {
        get => _IsOn(E_STATUS_FLAG.FLAG_N);
        private set mut => _Set(E_STATUS_FLAG.FLAG_N, value);
    }

    /// <summary>
    /// Overflow
    /// </summary>
    public bool V
    {
        get => _IsOn(E_STATUS_FLAG.FLAG_V);
        set mut => _Set(E_STATUS_FLAG.FLAG_V, value);
    }

    /// <summary>
    /// Unused
    /// </summary>
    public bool U
    {
        get => _IsOn(E_STATUS_FLAG.FLAG_U);
        private set mut => _Set(E_STATUS_FLAG.FLAG_U, value);
    }

    /// <summary>
    /// Break
    /// </summary>
    public bool B
    {
        get => _IsOn(E_STATUS_FLAG.FLAG_B);
        set mut => _Set(E_STATUS_FLAG.FLAG_B, value);
    }

    /// <summary>
    /// Decimal
    /// </summary>
    public bool D
    {
        get => _IsOn(E_STATUS_FLAG.FLAG_D);
        set mut => _Set(E_STATUS_FLAG.FLAG_D, value);
    }

    /// <summary>
    /// Interrupt Disable
    /// </summary>
    public bool I
    {
        get => _IsOn(E_STATUS_FLAG.FLAG_I);
        set mut => _Set(E_STATUS_FLAG.FLAG_I, value);
    }

    /// <summary>
    /// Zero
    /// </summary>
    public bool Z
    {
        get => _IsOn(E_STATUS_FLAG.FLAG_Z);
        private set mut => _Set(E_STATUS_FLAG.FLAG_Z, value);
    }

    /// <summary>
    /// Carry
    /// </summary>
    public bool C
    {
        get => _IsOn(E_STATUS_FLAG.FLAG_C);
        set mut => _Set(E_STATUS_FLAG.FLAG_C, value);
    }

    public static implicit operator StatusRegister(int value)
    {
        return StatusRegister((E_STATUS_FLAG)value);
    }

    private bool _IsOn(E_STATUS_FLAG flag)
    {
        return (_flags & (u8)flag) != 0;
    }

    private void _Set(E_STATUS_FLAG flag, bool isOn)  mut
    {
        if (isOn)
        {
            _flags |= (u8)flag;
        }
        else
        {
            _flags &= ~(u8)flag;
        }
    }

    public void SetZfromValue(u8 v) mut
    {
        Z = v == 0;
    }

    public void SetNfromValue(u8 v) mut
    {
        N = (v & (u8)E_STATUS_FLAG.FLAG_N) != 0;
    }

    public override void ToString(String sb)
    {
        sb.Append(N ? 'N' : '.');
        sb.Append(V ? 'V' : '.');
        sb.Append(U ? '.' : '@');
        sb.Append(B ? 'B' : '.');
        sb.Append(D ? 'D' : '.');
        sb.Append(I ? 'I' : '.');
        sb.Append(Z ? 'Z' : '.');
        sb.Append(C ? 'C' : '.');
    }
}