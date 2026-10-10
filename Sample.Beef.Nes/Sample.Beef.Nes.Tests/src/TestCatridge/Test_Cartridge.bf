using Sample.Beef.Nes.ImplCartridge;
using System;
namespace Sample.Beef.Nes.Tests.TestCatridge;

class Test_Cartridge
{
    [Test]
    public static void Test2_Cartridge_RejectInvalidFile()
    {
        // Test 2: Invalid file
        u8[256] data = .();

        switch (Header_iNes.Validate(data)) {
        case .Ok:
            Runtime.FatalError();
        case .Err(let err):
            Assert.Equal(err, .InvalidHeaderMagic);
        }
    }
}