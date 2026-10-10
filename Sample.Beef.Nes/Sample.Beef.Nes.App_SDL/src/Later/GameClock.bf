using SDL3;
using System;

namespace Sample.Beef.Nes.App_SDL.Later;

// todo accmulate tick / delta tick

class GameClock
{
    uint64 _performanceFrequency;
    uint64 _performanceCounter_curr;
    uint64 _performanceCounter_prev;

    float _accumulatorForFixedDeltaTimeSec;
    float _accumulatorForFps;
    uint _frameCount;

    public float CurrentFps { get; private set; }
    public uint TargetFps { get; private set; }
    public float DeltaTimeSec { get; private set; }
    public float FixedDeltaTimeSec { get; private set; }
    public bool IsFpsUpdated { get; private set; }
    public float Alpha { get; private set; }

    [Inline]
    public void Init(uint targetFps)
    {
        TargetFps = targetFps;
        FixedDeltaTimeSec = 1.0f / targetFps;

        _performanceFrequency = SDL_GetPerformanceFrequency();
        _performanceCounter_curr = SDL_GetPerformanceCounter();
        _performanceCounter_prev = _performanceCounter_curr;
    }

    [Inline]
    public void UpdatePerFrameLoop()
    {
        _performanceCounter_curr = SDL_GetPerformanceCounter();
        uint64 diff = _performanceCounter_curr - _performanceCounter_prev;
        _performanceCounter_prev = _performanceCounter_curr;

        DeltaTimeSec = (float)diff / (float)_performanceFrequency;
        _accumulatorForFixedDeltaTimeSec += DeltaTimeSec;

        // for Fps
        {
            _accumulatorForFps += DeltaTimeSec;

            _frameCount++;

            IsFpsUpdated = _accumulatorForFps >= 1.0f;

            if (IsFpsUpdated)
            {
                CurrentFps = (float)_frameCount  / _accumulatorForFps;
                _frameCount = 0;
                _accumulatorForFps -= 1.0f;
            }
        }
    }

    [Inline]
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
    uint64 _performanceFrequency;
    uint64 _performanceCounter_curr;
    uint64 _performanceCounter_prev;

    uint64 _performanceCounter_prev_for_fps;
    float _accumulatorForFixedDeltaTimeSec;
    float _accumulatorForFps;
    uint _frameCount;

    public float CurrentFps { get; private set; }
    public uint TargetFps { get; private set; }
    public float DeltaTimeSec { get; private set; }
    public float FixedDeltaTimeSec { get; private set; }
    public bool IsFpsUpdated { get; private set; }
    public float Alpha { get; private set; }

    [Inline]
    public void Init(uint targetFps)
    {
        TargetFps = targetFps;
        FixedDeltaTimeSec = 1.0f / targetFps;

        _performanceFrequency = SDL_GetPerformanceFrequency();
        _performanceCounter_curr = SDL_GetPerformanceCounter();
        _performanceCounter_prev = _performanceCounter_curr;
        _performanceCounter_prev_for_fps = _performanceCounter_curr;
    }

    [Inline]
    public void UpdatePerFrameLoop()
    {
        _performanceCounter_curr = SDL_GetPerformanceCounter();
        uint64 diff = _performanceCounter_curr - _performanceCounter_prev;

        DeltaTimeSec = (float)diff / (float)_performanceFrequency;

        // for Fps
        {
            uint64 diff_for_fps = _performanceCounter_curr - _performanceCounter_prev_for_fps;
            _performanceCounter_prev_for_fps = _performanceCounter_curr;
            _accumulatorForFps += (float)diff_for_fps / (float)_performanceFrequency;



            _frameCount++;

            IsFpsUpdated = _accumulatorForFps >= 1.0f;

            if (IsFpsUpdated)
            {
                CurrentFps = (float)_frameCount  / _accumulatorForFps;
                _frameCount = 0;
                _accumulatorForFps -= 1.0f;
            }
        }
    }

    [Inline]
    public bool TryConsumeFixedDeltaTimeSec()
    {
        if (_performanceCounter_curr != _performanceCounter_prev)
        {
            if (DeltaTimeSec > FixedDeltaTimeSec)
            {
                _performanceCounter_prev = _performanceCounter_curr;
                return true;
            }
        }

        Alpha = DeltaTimeSec / FixedDeltaTimeSec;
        return false;
    }
}