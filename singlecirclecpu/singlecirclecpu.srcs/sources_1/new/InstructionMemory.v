`timescale 1ns / 1ps

// READ_ONLY MEMORY

module InstructionMemory(
    input [31:0] address,
    output [31:0] readResult
    );

    reg [31:0] data [1023:0];

    initial
    begin
        $readmemh("D:\\CSI\\mips1.txt", data);
    end
    //读数据不需要时钟沿
    assign readResult = data[address[11:2]];
    
endmodule
