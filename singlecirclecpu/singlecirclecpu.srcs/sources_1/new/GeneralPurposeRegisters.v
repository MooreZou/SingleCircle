`timescale 1ns / 1ps
//通用寄存器从0到31

module GeneralPurposeRegisters(
    input [4:0] readNoA,
    input [4:0] readNoB,
    input reset,
    input [4:0] writeNo,
    input writeEnabled,
    input [31:0] writeContent,
    input clock,
    output [31:0] readResultA,
    output [31:0] readResultB
    );

    reg [31:0] GR [31:0];
    integer i;

    initial
    begin
        for(i=0; i<32; i=i+1)
        begin
            GR[i] <= 0;
        end
    end

    always @(posedge clock)
    begin
        if(reset)
        begin
            for(i=0;i<32;i=i+1)
            begin
                GR[i] <= 0;
            end
        end
        //零寄存器不能进行写操作
        else if(writeEnabled && writeNo != 0)
        begin
            GR[writeNo] <= writeContent;
        end
    end

    assign readResultA = GR[readNoA];
    assign readResultB = GR[readNoB];

endmodule