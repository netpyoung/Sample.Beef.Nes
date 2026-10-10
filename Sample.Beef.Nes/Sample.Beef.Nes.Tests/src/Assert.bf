using System;
namespace Sample.Beef.Nes.Tests;

static class Assert
{
    public static void True(bool condition, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
    {
        if (!condition)
        {
            if ((!Compiler.IsComptime) && (Runtime.CheckAssertError != null) && (Runtime.CheckAssertError(.Test, error, filePath, line) == .Ignore))
                return;
            String failStr = scope .()..AppendF("Assert failed: {} at line {} in {}", error, line, filePath);
            if (Compiler.IsComptime)
                Internal.FatalError(failStr);
            else
                Internal.[Friend]Test_Error(failStr);
        }
    }

    [Inline]
    public static void False(bool condition, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
    {
        True(!condition, error, filePath, line);
    }

    [Inline]
    public static void Equal<T>(T expected, T actual, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
    {
        True(expected == actual, error, filePath, line);
    }

    [Inline]
    public static void NotEqual<T>(T expected, T actual, String error = Compiler.CallerExpression[0], String filePath = Compiler.CallerFilePath, int line = Compiler.CallerLineNum)
    {
        True(expected != actual, error, filePath, line);
    }
}

// TODO S for struct


// Test_BRK_RTI
// Test_JSR_RTS
//Test_PHA_PHP_PLA_PLP
//Test_TAX_TAY_TXA_TYA_TSX_TXS