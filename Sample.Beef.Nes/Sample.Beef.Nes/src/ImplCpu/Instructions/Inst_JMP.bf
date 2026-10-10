namespace Sample.Beef.Nes.ImplCpu.Instructions;

extension Inst
{
    public static void JMP_ABSOLUTE(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.PC = Addressing.Absolute(cpu);

        outCpuCycle = 3;
    }

    public static void JMP_INDIRECT(Cpu cpu, out int outCpuCycle)
    {
        cpu.Register.PC = Addressing.Indirect(cpu);

        outCpuCycle = 5;
    }
}
