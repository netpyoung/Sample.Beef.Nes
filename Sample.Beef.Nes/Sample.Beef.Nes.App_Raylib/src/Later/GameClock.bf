using RaylibBeef;
using System;

namespace Sample.Beef.Nes.App_Raylib.Later;

class GameClock
{
    private double _previousTime;

    private float _accumulatorForFixedDeltaTimeSec;
    private float _accumulatorForFps;
    private uint _frameCount;

    public float CurrentFps { get; private set; }
    public uint TargetFps { get; private set; }
    public float DeltaTimeSec { get; private set; }
    public float FixedDeltaTimeSec { get; private set; }
    public bool IsFpsUpdated { get; private set; }
    public float Alpha { get; private set; }

    public void Init(uint targetFps)
    {
        TargetFps = targetFps;
        FixedDeltaTimeSec = 1.0f / targetFps;
        _previousTime = Raylib.GetTime();
    }

    public void UpdatePerFrameLoop()
    {
        double currentTime = Raylib.GetTime();
        DeltaTimeSec = (float)(currentTime - _previousTime);
        _previousTime = currentTime;

        //const float MIN_DELTA_TIME_SEC = 0.25f;
        //DeltaTimeSec = Math.Min(DeltaTimeSec, MIN_DELTA_TIME_SEC);

        _accumulatorForFixedDeltaTimeSec += DeltaTimeSec;

        // for FPS
        {
            _accumulatorForFps += DeltaTimeSec;

            _frameCount++;

            IsFpsUpdated = _accumulatorForFps >= 1.0f;

            if (IsFpsUpdated)
            {
                CurrentFps = (float)_frameCount / _accumulatorForFps;
                _frameCount = 0;
                _accumulatorForFps -= 1.0f;
            }
        }
    }

    public bool TryConsumeFixedDeltaTimeSec()
    {
        if (_accumulatorForFixedDeltaTimeSec >= FixedDeltaTimeSec)
        {
            _accumulatorForFixedDeltaTimeSec -= FixedDeltaTimeSec;
            return true;
        }

        Alpha = _accumulatorForFixedDeltaTimeSec / FixedDeltaTimeSec;
        return false;
    }
}

class GameClock2
{
    private double _currentTime;
    private double _previousTime;

    private double _previousTime_for_fps;
    private float _accumulatorForFixedDeltaTimeSec;
    private float _accumulatorForFps;
    private uint _frameCount;

    public float CurrentFps { get; private set; }
    public uint TargetFps { get; private set; }
    public float DeltaTimeSec { get; private set; }
    public float FixedDeltaTimeSec { get; private set; }
    public bool IsFpsUpdated { get; private set; }
    public float Alpha { get; private set; }

    public void Init(uint targetFps)
    {
        TargetFps = targetFps;
        FixedDeltaTimeSec = 1.0f / targetFps;
        _currentTime = Raylib.GetTime();
        _previousTime = _currentTime;
        _previousTime_for_fps = _currentTime;
    }

    public void UpdatePerFrameLoop()
    {
        _currentTime = Raylib.GetTime();
        DeltaTimeSec = (float)(_currentTime - _previousTime);


        // for FPS
        {
            double diff_for_fps = _currentTime - _previousTime_for_fps;
            _previousTime_for_fps = _currentTime;
            _accumulatorForFps += (float)diff_for_fps;

            _frameCount++;

            IsFpsUpdated = _accumulatorForFps >= 1.0f;

            if (IsFpsUpdated)
            {
                CurrentFps = (float)_frameCount / _accumulatorForFps;
                _frameCount = 0;
                _accumulatorForFps -= 1.0f;
            }
        }
    }

    public bool TryConsumeFixedDeltaTimeSec()
    {
        if (_previousTime != _currentTime)
        {
            if (DeltaTimeSec >= FixedDeltaTimeSec)
            {
                _previousTime = _currentTime;
                return true;
            }
        }

        Alpha = DeltaTimeSec / FixedDeltaTimeSec;
        return false;
    }
}