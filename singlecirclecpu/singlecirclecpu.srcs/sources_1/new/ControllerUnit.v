`timescale 1ns / 1ps

// addu: 000000, rs, rt, rd, 00000, 100001 => rd := rs + rt
// subu: 000000, rs, rt, rd, 00000, 100011 => rd := rs - rt
// ori:  001101, rs, rt, 16'imm => rt := rs or imm
// lw:   100011, base(rs), rt, offset(imm) => rt := M[base+offset]
// sw:   101011, base(rs), rt, offset(imm) => M[base+offset] := rt
// beq:  000100, rs, rt, offset(imm) => if rs=rt then PC = PC + offset
// lui:  001111, 00000, rt, imm => rt := (imm<<16) | 0
// jal:  000011, target  => ($ra := PC + 8;) PC := PC[31:28] | target[25:0] | 2'b00
// jr:   000000, rs, 00000 00000, hint, 001000 => PC := rs
// syscall: 000000, [19:0] code, 001100 => $finish

module ControllerUnit(
    input [5:0] Op,
    input [5:0] Func,
    output reg [1:0] RegDst,      // 00:Rt;01:Rd;10:$ra 
    output reg RegWrite,    // write or not
    output reg [1:0] ALUSrc,      // 00:GR[rt];01:SignExtended imm;10:lui;11:0
    output reg [1:0] PCSrc,       // 00:jr;01:beq;10:jal
    output reg PCJumpEnabled,
    output reg MemRead,     // read from DM or not
    output reg MemWrite,    // write into DM or not
    output reg [1:0] MemToReg,    // Reg data source
    output reg [5:0] ALUOp // ALU controller signal  
    );

    always @(*)
    begin
        // RegDst
        // 00:Rt;01:Rd;10:$ra 
        if(Op == 6'b000000 && Func != 6'b001100 && Func != 6'b001000) // no syscall or jr
            RegDst <= 2'b01; // R
        else if(Op == 6'b100011 || Op == 6'b001101 || Op == 6'b001111)
            RegDst <= 2'b00; // lw、ori、lui
        else if(Op == 6'b000011) // jal
            RegDst <= 2'b10;
        else
            RegDst <= 2'b11;

        // RegWrite: lw、ori、jal、lui、R
        if(Op == 6'b000000 || Op == 6'b100011 || Op == 6'b001101 || Op == 6'b000011 || Op == 6'b001111)
            RegWrite <= 1;
        else
            RegWrite <= 0;
        
        // ALUSrc
        // 00:GR[rt];01:SignExtended imm;10:lui;11:0
        if(Op == 6'b000000 || Op == 6'b000100)
            ALUSrc <= 2'b00; // R-i、beq
        else if(Op == 6'b100011 || Op == 6'b101011 || Op == 6'b001101)
            ALUSrc <= 2'b01; // lw、sw、ori
        else if(Op == 6'b001111)
            ALUSrc <= 2'b10; // lui
        else // if(Op == 6'b000011)
            ALUSrc <= 2'b11; // jal and others
        
        // PCSrc & PCJumpEnabled
        // 00:jr;01:beq;10:jal
        if(Op == 6'b000000 && Func == 6'b001000) // jr
        begin
            PCJumpEnabled <= 1;
            PCSrc <= 2'b00;
        end
        else if(Op == 6'b000100) // beq
        begin
            PCJumpEnabled <= 1; // need to & ALUResult == zero
            PCSrc <= 2'b01;
        end
        else if(Op == 6'b000011) // jal
        begin
            PCJumpEnabled <= 1;
            PCSrc <= 2'b10;
        end
        else
        begin
            PCJumpEnabled <= 0;
            PCSrc <= 2'b11;
        end

        // MemRead
        if(Op == 6'b100011)// lw
            MemRead <= 1;
        else
            MemRead <= 0;

        // MemWrite
        if(Op == 6'b101011) // sw
            MemWrite <= 1;
        else
            MemWrite <= 0;

        // MemToReg
        // Reg data source
        // 00:ALU;01:Memp;10:PC + 4;11 other(ALU into Regs)
        if(Op == 6'b000000)
            MemToReg <= 2'b00; // R侏峺綜
        else if(Op == 6'b100011)
            MemToReg <= 2'b01; // lw
        else if(Op == 6'b000011) // jal
            MemToReg <= 2'b10;
        else
            MemToReg <= 2'b00;

        // ALUOp
        if(Op == 6'b000000)
            ALUOp <= Func;
        else if(Op == 6'b100011 || Op == 6'b101011) // lw or sw
            ALUOp <= 6'b100001; // A+B
        else if(Op == 6'b001101) // ori
            ALUOp <= 6'b100101; // A|B
        else if(Op == 6'b000100) // beq
            ALUOp <= 6'b100011; // A-B
        else if(Op == 6'b001111) // lui
            ALUOp <= 6'b100101; // 0|B
        else
            ALUOp <= 6'b100001;

    end

endmodule