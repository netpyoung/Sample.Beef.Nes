using Sample.Beef.Nes.ImplCpu.Instructions;

namespace Sample.Beef.Nes.ImplCpu;

static class OpCodeContainer
{
    public function void FuncExecutor(Cpu cpu, out int cycle);

    private readonly static FuncExecutor[256] OpCodeInfos;

    static this()
    {
        // LDA x8
        OpCodeInfos[0xA9] = => Inst.LDA_IMMEDIATE;
        OpCodeInfos[0xA5] = => Inst.LDA_ZERO_PAGE;
        OpCodeInfos[0xB5] = => Inst.LDA_ZERO_PAGE_X;
        OpCodeInfos[0xAD] = => Inst.LDA_ABSOLUTE;
        OpCodeInfos[0xBD] = => Inst.LDA_ABSOLUTE_X;
        OpCodeInfos[0xB9] = => Inst.LDA_ABSOLUTE_Y;
        OpCodeInfos[0xA1] = => Inst.LDA_INDIRECT_X;
        OpCodeInfos[0xB1] = => Inst.LDA_INDIRECT_Y;

        // LDX x5
        OpCodeInfos[0xA2] = => Inst.LDX_IMMEDIATE;
        OpCodeInfos[0xA6] = => Inst.LDX_ZERO_PAGE;
        OpCodeInfos[0xB6] = => Inst.LDX_ZERO_PAGE_Y;
        OpCodeInfos[0xAE] = => Inst.LDX_ABSOLUTE;
        OpCodeInfos[0xBE] = => Inst.LDX_ABSOLUTE_Y;

        // LDY x5
        OpCodeInfos[0xA0] = => Inst.LDY_IMMEDIATE;
        OpCodeInfos[0xA4] = => Inst.LDY_ZERO_PAGE;
        OpCodeInfos[0xB4] = => Inst.LDY_ZERO_PAGE_X;
        OpCodeInfos[0xAC] = => Inst.LDY_ABSOLUTE;
        OpCodeInfos[0xBC] = => Inst.LDY_ABSOLUTE_X;

        // STA x7
        OpCodeInfos[0x85] = => Inst.STA_ZERO_PAGE;
        OpCodeInfos[0x95] = => Inst.STA_ZERO_PAGE_X;
        OpCodeInfos[0x8D] = => Inst.STA_ABSOLUTE;
        OpCodeInfos[0x9D] = => Inst.STA_ABSOLUTE_X;
        OpCodeInfos[0x99] = => Inst.STA_ABSOLUTE_Y;
        OpCodeInfos[0x81] = => Inst.STA_INDIRECT_X;
        OpCodeInfos[0x91] = => Inst.STA_INDIRECT_Y;

        // STX x3
        OpCodeInfos[0x86] = => Inst.STX_ZERO_PAGE;
        OpCodeInfos[0x96] = => Inst.STX_ZERO_PAGE_Y;
        OpCodeInfos[0x8E] = => Inst.STX_ABSOLUTE;

        // STY x3
        OpCodeInfos[0x84] = => Inst.STY_ZERO_PAGE;
        OpCodeInfos[0x94] = => Inst.STY_ZERO_PAGE_X;
        OpCodeInfos[0x8C] = => Inst.STY_ABSOLUTE;

        // NOP
        OpCodeInfos[0xEA] = => Inst.NOP;

        // INX INY DEX DEY
        OpCodeInfos[0xE8] = => Inst.INX;
        OpCodeInfos[0xC8] = => Inst.INY;
        OpCodeInfos[0xCA] = => Inst.DEX;
        OpCodeInfos[0x88] = => Inst.DEY;

        // INC x4
        OpCodeInfos[0xE6] = => Inst.INC_ZERO_PAGE;
        OpCodeInfos[0xF6] = => Inst.INC_ZERO_PAGE_X;
        OpCodeInfos[0xEE] = => Inst.INC_ABSOLUTE;
        OpCodeInfos[0xFE] = => Inst.INC_ABSOLUTE_X;

        // DEC x4
        OpCodeInfos[0xC6] = => Inst.DEC_ZERO_PAGE;
        OpCodeInfos[0xD6] = => Inst.DEC_ZERO_PAGE_X;
        OpCodeInfos[0xCE] = => Inst.DEC_ABSOLUTE;
        OpCodeInfos[0xDE] = => Inst.DEC_ABSOLUTE_X;

        // ADC x8
        OpCodeInfos[0x69] = => Inst.ADC_IMMEDIATE;
        OpCodeInfos[0x65] = => Inst.ADC_ZERO_PAGE;
        OpCodeInfos[0x75] = => Inst.ADC_ZERO_PAGE_X;
        OpCodeInfos[0x6D] = => Inst.ADC_ABSOLUTE;
        OpCodeInfos[0x7D] = => Inst.ADC_ABSOLUTE_X;
        OpCodeInfos[0x79] = => Inst.ADC_ABSOLUTE_Y;
        OpCodeInfos[0x61] = => Inst.ADC_INDIRECT_X;
        OpCodeInfos[0x71] = => Inst.ADC_INDIRECT_Y;

        // SBC x8
        OpCodeInfos[0xE9] = => Inst.SBC_IMMEDIATE;
        OpCodeInfos[0xE5] = => Inst.SBC_ZERO_PAGE;
        OpCodeInfos[0xF5] = => Inst.SBC_ZERO_PAGE_X;
        OpCodeInfos[0xED] = => Inst.SBC_ABSOLUTE;
        OpCodeInfos[0xFD] = => Inst.SBC_ABSOLUTE_X;
        OpCodeInfos[0xF9] = => Inst.SBC_ABSOLUTE_Y;
        OpCodeInfos[0xE1] = => Inst.SBC_INDIRECT_X;
        OpCodeInfos[0xF1] = => Inst.SBC_INDIRECT_Y;

        // TAX TXA TAY TYA TSX TXS
        OpCodeInfos[0xAA] = => Inst.TAX;
        OpCodeInfos[0x8A] = => Inst.TXA;
        OpCodeInfos[0xA8] = => Inst.TAY;
        OpCodeInfos[0x98] = => Inst.TYA;
        OpCodeInfos[0xBA] = => Inst.TSX;
        OpCodeInfos[0x9A] = => Inst.TXS;

        // AND x8
        OpCodeInfos[0x29] = => Inst.AND_IMMEDIATE;
        OpCodeInfos[0x25] = => Inst.AND_ZERO_PAGE;
        OpCodeInfos[0x2D] = => Inst.AND_ABSOLUTE;
        OpCodeInfos[0x35] = => Inst.AND_ZERO_PAGE_X;
        OpCodeInfos[0x3D] = => Inst.AND_ABSOLUTE_X;
        OpCodeInfos[0x39] = => Inst.AND_ABSOLUTE_Y;
        OpCodeInfos[0x21] = => Inst.AND_INDIRECT_X;
        OpCodeInfos[0x31] = => Inst.AND_INDIRECT_Y;

        // ORA x8
        OpCodeInfos[0x09] = => Inst.ORA_IMMEDIATE;
        OpCodeInfos[0x05] = => Inst.ORA_ZERO_PAGE;
        OpCodeInfos[0x15] = => Inst.ORA_ZERO_PAGE_X;
        OpCodeInfos[0x0D] = => Inst.ORA_ABSOLUTE;
        OpCodeInfos[0x1D] = => Inst.ORA_ABSOLUTE_X;
        OpCodeInfos[0x19] = => Inst.ORA_ABSOLUTE_Y;
        OpCodeInfos[0x01] = => Inst.ORA_INDIRECT_X;
        OpCodeInfos[0x11] = => Inst.ORA_INDIRECT_Y;

        // EOR x8
        OpCodeInfos[0x49] = => Inst.EOR_IMMEDIATE;
        OpCodeInfos[0x45] = => Inst.EOR_ZERO_PAGE;
        OpCodeInfos[0x55] = => Inst.EOR_ZERO_PAGE_X;
        OpCodeInfos[0x4D] = => Inst.EOR_ABSOLUTE;
        OpCodeInfos[0x5D] = => Inst.EOR_ABSOLUTE_X;
        OpCodeInfos[0x59] = => Inst.EOR_ABSOLUTE_Y;
        OpCodeInfos[0x41] = => Inst.EOR_INDIRECT_X;
        OpCodeInfos[0x51] = => Inst.EOR_INDIRECT_Y;

        // BIT x2
        OpCodeInfos[0x24] = => Inst.BIT_ZERO_PAGE;
        OpCodeInfos[0x2C] = => Inst.BIT_ABSOLUTE;

        // ASL x5
        OpCodeInfos[0x0A] = => Inst.ASL_ACCUMULATOR;
        OpCodeInfos[0x06] = => Inst.ASL_ZERO_PAGE;
        OpCodeInfos[0x16] = => Inst.ASL_ZERO_PAGE_X;
        OpCodeInfos[0x0E] = => Inst.ASL_ABSOLUTE;
        OpCodeInfos[0x1E] = => Inst.ASL_ABSOLUTE_X;

        // LSR x5
        OpCodeInfos[0x4A] = => Inst.LSR_ACCUMULATOR;
        OpCodeInfos[0x46] = => Inst.LSR_ZERO_PAGE;
        OpCodeInfos[0x56] = => Inst.LSR_ZERO_PAGE_X;
        OpCodeInfos[0x4E] = => Inst.LSR_ABSOLUTE;
        OpCodeInfos[0x5E] = => Inst.LSR_ABSOLUTE_X;

        // ROL x5
        OpCodeInfos[0x2A] = => Inst.ROL_ACCUMULATOR;
        OpCodeInfos[0x26] = => Inst.ROL_ZERO_PAGE;
        OpCodeInfos[0x36] = => Inst.ROL_ZERO_PAGE_X;
        OpCodeInfos[0x2E] = => Inst.ROL_ABSOLUTE;
        OpCodeInfos[0x3E] = => Inst.ROL_ABSOLUTE_X;

        // ROR x5
        OpCodeInfos[0x6A] = => Inst.ROR_ACCUMULATOR;
        OpCodeInfos[0x66] = => Inst.ROR_ZERO_PAGE;
        OpCodeInfos[0x76] = => Inst.ROR_ZERO_PAGE_X;
        OpCodeInfos[0x6E] = => Inst.ROR_ABSOLUTE;
        OpCodeInfos[0x7E] = => Inst.ROR_ABSOLUTE_X;

        // CMP x8
        OpCodeInfos[0xC9] = => Inst.CMP_IMMEDIATE;
        OpCodeInfos[0xC5] = => Inst.CMP_ZERO_PAGE;
        OpCodeInfos[0xD5] = => Inst.CMP_ZERO_PAGE_X;
        OpCodeInfos[0xCD] = => Inst.CMP_ABSOLUTE;
        OpCodeInfos[0xDD] = => Inst.CMP_ABSOLUTE_X;
        OpCodeInfos[0xD9] = => Inst.CMP_ABSOLUTE_Y;
        OpCodeInfos[0xC1] = => Inst.CMP_INDIRECT_X;
        OpCodeInfos[0xD1] = => Inst.CMP_INDIRECT_Y;

        // CPX x3
        OpCodeInfos[0xE0] = => Inst.CPX_IMMEDIATE;
        OpCodeInfos[0xE4] = => Inst.CPX_ZERO_PAGE;
        OpCodeInfos[0xEC] = => Inst.CPX_ABSOLUTE;

        // CPY x3
        OpCodeInfos[0xC0] = => Inst.CPY_IMMEDIATE;
        OpCodeInfos[0xC4] = => Inst.CPY_ZERO_PAGE;
        OpCodeInfos[0xCC] = => Inst.CPY_ABSOLUTE;

        // JMP x2
        OpCodeInfos[0x4C] = => Inst.JMP_ABSOLUTE;
        OpCodeInfos[0x6C] = => Inst.JMP_INDIRECT;

        // JSR RTS
        OpCodeInfos[0x20] = => Inst.JSR;
        OpCodeInfos[0x60] = => Inst.RTS;

        // BRK RTI
        OpCodeInfos[0x00] = => Inst.BRK;
        OpCodeInfos[0x40] = => Inst.RTI;

        // CLC SEC CLI SEI CLD SED CLV
        OpCodeInfos[0x18] = => Inst.CLC;
        OpCodeInfos[0x38] = => Inst.SEC;
        OpCodeInfos[0x58] = => Inst.CLI;
        OpCodeInfos[0x78] = => Inst.SEI;
        OpCodeInfos[0xD8] = => Inst.CLD;
        OpCodeInfos[0xF8] = => Inst.SED;
        OpCodeInfos[0xB8] = => Inst.CLV;

        // PHA PHP PLA PLP
        OpCodeInfos[0x48] = => Inst.PHA;
        OpCodeInfos[0x08] = => Inst.PHP;
        OpCodeInfos[0x68] = => Inst.PLA;
        OpCodeInfos[0x28] = => Inst.PLP;

        // BCC BCS BEQ BNE BPL BMI BVC BVS
        OpCodeInfos[0x90] = => Inst.BCC;
        OpCodeInfos[0xB0] = => Inst.BCS;
        OpCodeInfos[0xF0] = => Inst.BEQ;
        OpCodeInfos[0xD0] = => Inst.BNE;
        OpCodeInfos[0x10] = => Inst.BPL;
        OpCodeInfos[0x30] = => Inst.BMI;
        OpCodeInfos[0x50] = => Inst.BVC;
        OpCodeInfos[0x70] = => Inst.BVS;
    }


    public static FuncExecutor GetFuncOrNull(u8 opCode)
    {
        return OpCodeInfos[opCode];
    }
}