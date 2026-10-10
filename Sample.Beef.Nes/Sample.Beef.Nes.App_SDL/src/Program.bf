using System;
using SDL3;
using System.Collections;
using Sample.Beef.Nes.ImplController;
using Sample.Beef.Nes.App_SDL.Later;

namespace Sample.Beef.Nes.App_SDL;

static
{
    //public static readonly GameClock GAME_CLOCK = new GameClock() ~ delete _;
    public static readonly GameClock2 GAME_CLOCK = new GameClock2() ~ delete _;
}

class Program
{
    const int SCALE = 3;
    const int WIDTH = 256;
    const int HEIGHT = 240;
    const int WINDOW_WIDTH = SCALE * WIDTH;
    const int WINDOW_HEIGHT = SCALE * HEIGHT;
    static String S_TITLE = "Sample.Beef.Nes.App_SDL";

    static Dictionary<SDL_Scancode, E_BUTTON> Dic_ScanCode_To_Button = new Dictionary<SDL_Scancode, E_BUTTON>() ~ delete _;

    public static void Main(String[] args)
    {
        bool isUsingDummy = true;
        Nes nes = null;
        if (args.Count == 0)
        {
            isUsingDummy = true;
            nes = Nes.CreateDummyCartridge();
        }
        else
        {
            isUsingDummy = false;
            StringView path = args[0];
            nes = Nes.CreateFromPath(path);
        }
        defer delete nes;

        u8[] buffer = CreateSampleBuffer();
        defer delete buffer;
        Dic_ScanCode_To_Button[.SDL_SCANCODE_S] = .A;
        Dic_ScanCode_To_Button[.SDL_SCANCODE_A] = .B;
        Dic_ScanCode_To_Button[.SDL_SCANCODE_Q] = .SELECT;
        Dic_ScanCode_To_Button[.SDL_SCANCODE_W] = .START;
        Dic_ScanCode_To_Button[.SDL_SCANCODE_UP] = .UP;
        Dic_ScanCode_To_Button[.SDL_SCANCODE_DOWN] = .DOWN;
        Dic_ScanCode_To_Button[.SDL_SCANCODE_LEFT] = .LEFT;
        Dic_ScanCode_To_Button[.SDL_SCANCODE_RIGHT] = .RIGHT;

        SDL_InitFlags initFlag = .SDL_INIT_AUDIO | .SDL_INIT_VIDEO | .SDL_INIT_EVENTS;
        if (!SDL_Init(initFlag))
        {
            Console.Error.WriteLine($"err: {scope String(SDL_GetError())}");
            Environment.Exit(1);
        }
        defer SDL_Quit();

        SDL_Window* window = SDL_CreateWindow(
            S_TITLE,
            WINDOW_WIDTH,
            WINDOW_HEIGHT,
            0
            );
        if (window == null)
        {
            Console.Error.WriteLine($"err: {scope String(SDL_GetError())}");
            Environment.Exit(1);
        }
        defer SDL_DestroyWindow(window);


        SDL_Renderer* renderer = SDL_CreateRenderer(window, null);
        if (renderer == null)
        {
            Console.Error.WriteLine($"err: {scope String(SDL_GetError())}");
            Environment.Exit(1);
        }
        defer SDL_DestroyRenderer(renderer);

        SDL_Texture* texture = SDL_CreateTexture(
            renderer,
            .SDL_PIXELFORMAT_ABGR8888,
            .SDL_TEXTUREACCESS_STREAMING,
            WIDTH,
            HEIGHT
            );
        if (texture == null)
        {
            Console.Error.WriteLine($"err: {scope String(SDL_GetError())}");
            Environment.Exit(1);
        }
        defer SDL_DestroyTexture(texture);


        SDL_AudioSpec spec = .();
        spec.freq  = 44100;
        spec.format = .SDL_AUDIO_F32;
        spec.channels = 1;

        SDL_AudioDeviceID audioDevice = SDL_OpenAudioDevice(0xFFFFFFFF, &spec);
        if (audioDevice == 0)
        {
            Console.Error.WriteLine($"err: {scope String(SDL_GetError())}");
            Environment.Exit(1);
        }
        defer SDL_CloseAudioDevice(audioDevice);

        SDL_AudioStream* audioStream = SDL_CreateAudioStream(&spec, &spec);
        if (audioStream == null)
        {
            Console.Error.WriteLine($"err: {scope String(SDL_GetError())}");
            Environment.Exit(1);
        }
        defer SDL_DestroyAudioStream(audioStream);


        // https://github.com/libsdl-org/SDL/commit/7dd4f1ec22da4a0f230ceabfc19c3298544548a0
        //SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");

        SDL_SetTextureScaleMode(texture, .SDL_SCALEMODE_NEAREST);

        if (!SDL_BindAudioStream(audioDevice, audioStream))
        {
            Console.Error.WriteLine($"err: {scope String(SDL_GetError())}");
            Environment.Exit(1);
        }


        float[1024] audioBuffer = .();

        GAME_CLOCK.Init(targetFps: 60);

        SDL_Event sdlEvent = default;
        FRAME_LOOP:while (true)
        {
            GAME_CLOCK.UpdatePerFrameLoop();

            // Event Handling
            SDL_PumpEvents();

            while (SDL_PollEvent(&sdlEvent))
            {
                switch ((SDL_EventType)sdlEvent.type)
                {
                case .SDL_EVENT_KEY_DOWN:
                    if (sdlEvent.key.scancode == .SDL_SCANCODE_ESCAPE)
                    {
                        break FRAME_LOOP;
                    }
                    if (Dic_ScanCode_To_Button.TryGetValue(sdlEvent.key.scancode, let btn))
                    {
                        nes.CpuBus.Controller1.Press(btn);
                    }
                case .SDL_EVENT_KEY_UP:
                    if (Dic_ScanCode_To_Button.TryGetValue(sdlEvent.key.scancode, let btn))
                    {
                        nes.CpuBus.Controller1.Release(btn);
                    }
                case .SDL_EVENT_QUIT:
                    break FRAME_LOOP;
                case .SDL_EVENT_TERMINATING:
                    break FRAME_LOOP;
                default:
                }
            }

            if (GAME_CLOCK.IsFpsUpdated)
            {
                Console.WriteLine(GAME_CLOCK.CurrentFps);
            }

            while (GAME_CLOCK.TryConsumeFixedDeltaTimeSec())
            {
                // Emulate Step
                nes.RunFrame();
            }
            {
                // Render Screen

                if (isUsingDummy)
                {
                    SDL_UpdateTexture(texture, null, buffer.Ptr, WIDTH * 4);
                    SDL_RenderClear(renderer);
                    SDL_RenderTexture(renderer, texture, null, null);
                    SDL_RenderPresent(renderer);
                }
                else
                {
                    SDL_UpdateTexture(texture, null, nes.FrameBufferPtr, WIDTH * 4);
                    SDL_RenderClear(renderer);
                    SDL_RenderTexture(renderer, texture, null, null);
                    SDL_RenderPresent(renderer);
                }
            }
            {
                // Streaming Audio

                nes.Apu.FillSampleNonAlloc(audioBuffer, let bufferLen);
                if (bufferLen != 0)
                {
                    int queuedBytes = SDL_GetAudioStreamQueued(audioStream);
                    if (queuedBytes <= 8192 * 4)
                    {
                        SDL_PutAudioStreamData(audioStream, &audioBuffer, (int32)(bufferLen * sizeof(float)));
                    }
                }
            }
        }
    }

    static u8[] CreateSampleBuffer()
    {
        u8[] buffer = new u8[WIDTH * HEIGHT * 4];
        for (int y = 0; y < HEIGHT; ++y)
        {
            for (int x = 0; x < WIDTH; ++x)
            {
                int offset = (x + y * WIDTH) * 4;
                switch (y / 60)
                {
                case 0:
                    buffer[offset + 0] = 255;
                    buffer[offset + 1] = 0;
                    buffer[offset + 2] = 0;
                    break;
                case 1:
                    buffer[offset + 0] = 0;
                    buffer[offset + 1] = 255;
                    buffer[offset + 2] = 0;
                    break;
                case 2:
                    buffer[offset + 0] = 0;
                    buffer[offset + 1] = 0;
                    buffer[offset + 2] = 255;
                    break;
                default:
                    buffer[offset + 0] = 255;
                    buffer[offset + 1] = 255;
                    buffer[offset + 2] = 255;
                    break;

                }
                buffer[offset + 3] = 255;
            }
        }

        return buffer;
    }

}

