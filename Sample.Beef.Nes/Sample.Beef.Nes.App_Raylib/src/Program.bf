using System;
using System.Collections;
using RaylibBeef;
using Sample.Beef.Nes.ImplController;
using Sample.Beef.Nes.App_Raylib.Later;

namespace Sample.Beef.Nes.App_Raylib;

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

    static String S_TITLE = "Sample.Beef.Nes.App_Raylib";
    static Dictionary<KeyboardKey, E_BUTTON> Dic_Key_To_Button = new Dictionary<KeyboardKey, E_BUTTON>() ~ delete _;

    public static void Main(String[] args)
    {
        Dic_Key_To_Button[.KEY_S] = .A;
        Dic_Key_To_Button[.KEY_A] = .B;
        Dic_Key_To_Button[.KEY_Q] = .SELECT;
        Dic_Key_To_Button[.KEY_W] = .START;
        Dic_Key_To_Button[.KEY_UP] = .UP;
        Dic_Key_To_Button[.KEY_DOWN] = .DOWN;
        Dic_Key_To_Button[.KEY_LEFT] = .LEFT;
        Dic_Key_To_Button[.KEY_RIGHT] = .RIGHT;


        u8[] buffer = CreateSampleBuffer();
        defer delete buffer;

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

        Raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, S_TITLE);
        defer Raylib.CloseWindow();

        Raylib.InitAudioDevice();
        defer Raylib.CloseAudioDevice();

        Raylib.SetTargetFPS(0);

        float[1024] audioBuffer = .();

        Raylib.SetAudioStreamBufferSizeDefault(1024);

        AudioStream audioStream = Raylib.LoadAudioStream(44100, 32, 1);
        defer Raylib.UnloadAudioStream(audioStream);

        Raylib.PlayAudioStream(audioStream);

        Image image = Raylib.GenImageColor(WIDTH, HEIGHT, Color.Black);
        defer Raylib.UnloadImage(image);

        Texture2D texture = Raylib.LoadTextureFromImage(image);
        defer Raylib.UnloadTexture(texture);


        GAME_CLOCK.Init(targetFps: 60);
        String fpsStr = scope String();

        while (!Raylib.WindowShouldClose())
        {
            GAME_CLOCK.UpdatePerFrameLoop();

            // Event Handling
            for (let kvp in Dic_Key_To_Button)
            {
                if (Raylib.IsKeyPressed(kvp.key))
                {
                    nes.CpuBus.Controller1.Press(kvp.value);
                }
                if (Raylib.IsKeyReleased(kvp.key))
                {
                    nes.CpuBus.Controller1.Release(kvp.value);
                }
            }

            if (GAME_CLOCK.IsFpsUpdated)
            {
                fpsStr.Clear();
                fpsStr.Append((int)GAME_CLOCK.CurrentFps);
                fpsStr.Append(" FPS");

                Console.WriteLine(GAME_CLOCK.CurrentFps);
            }
            while (GAME_CLOCK.TryConsumeFixedDeltaTimeSec())
            {
                // Emulate Step
                nes.RunFrame();
            }

            // Render Screen
            if (isUsingDummy)
            {
                Raylib.UpdateTexture(texture, buffer.Ptr);
            }
            else
            {
                Raylib.UpdateTexture(texture, nes.FrameBufferPtr);
            }

            // Streaming Audio
            if (Raylib.IsAudioStreamProcessed(audioStream))
            {
                nes.Apu.FillSampleNonAlloc(audioBuffer, let bufferLen);
                if (bufferLen > 0)
                {
                    Raylib.UpdateAudioStream(audioStream, &audioBuffer, (int32)bufferLen);
                }
            }

            Raylib.BeginDrawing();
            Raylib.ClearBackground(Color.Black);
            Raylib.DrawTexturePro(texture, Rectangle(0, 0, WIDTH, HEIGHT), Rectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT), Vector2(0, 0), 0, Color.White);
            //Raylib.DrawFPS(0, 0);
            Raylib.DrawText(fpsStr, 0, 0, 20, .(255, 0, 0, 255));

            Raylib.EndDrawing();
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


namespace RaylibBeef
{
    extension Color
    {
        public static readonly Color Black = Color(0, 0, 0, 255);
        public static readonly Color White = Color(255, 255, 255, 255);
    }
}
