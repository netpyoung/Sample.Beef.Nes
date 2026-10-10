using System;
using Sample.Beef.Nes.ImplController;
namespace Sample.Beef.Nes.Tests.TestController;

class Test_Controller
{
    [Test]
    public static void Test_01()
    {
        // # Test 1: Press Start and read it back
        Controller ctrl = scope Controller();
        ctrl.Press(E_BUTTON.START);
        ctrl.Write(1);
        ctrl.Write(0);

        StringView[?] names = .("A", "B", "Select", "Start", "Up", "Down", "Left", "Right");
        bool[?] expected = .(false, false, false, true, false, false, false, false);

        bool[8] actual = .();
        for (int i = 0; i < names.Count; ++i)
        {
            StringView v = names[i];
            bool bit = ctrl.Read();
            actual[i] = bit;

            Console.WriteLine($"   Read #{i} ({v}): {bit}");
        }

        Assert.Equal(expected, actual);
    }

    [Test]
    public static void Test_02()
    {
        // # Test 2: Press multiple buttons
        Controller ctrl = scope Controller();
        ctrl.Press(E_BUTTON.A);
        ctrl.Press(E_BUTTON.START);
        ctrl.Press(E_BUTTON.RIGHT);
        ctrl.Write(1);
        ctrl.Write(0);

        StringView[?] names = .("A", "B", "Select", "Start", "Up", "Down", "Left", "Right");
        bool[?] expected = .(true, false, false, true, false, false, false, true);

        bool[8] actual = .();
        for (int i = 0; i < names.Count; ++i)
        {
            StringView v = names[i];
            bool bit = ctrl.Read();
            actual[i] = bit;

            Console.WriteLine($"   Read #{i} ({v}): {bit}");
        }

        Assert.Equal(expected, actual);
    }
}